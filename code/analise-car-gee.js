/**
 * PROJETO: Análise do Passivo de Reserva Legal em Imóveis > 4MF no Pará
 * AUTOR: Samuel Santos (NGEO/IDEFLOR-Bio)
 * FINALIDADE: Simular a redução de 80% para 50% conforme Lei 12.651/2012
 */

// 1. ATIVOS E LIMITES
var car = ee.FeatureCollection('projects/ee-samuelsantosambientalcourse/assets/sicar_pa_acima_4mf');
var para = ee.FeatureCollection("FAO/GAUL/2015/level1").filter(ee.Filter.eq('ADM1_NAME', 'Para'));

// 2. COLEÇÕES MAPBIOMAS (Landsat p/ 2008 e Sentinel-2 p/ 2022)
var col9 = ee.Image('projects/mapbiomas-public/assets/brazil/lulc/collection9/mapbiomas_collection90_integration_v1');
var col10 = ee.Image('projects/mapbiomas-public/assets/brazil/lulc/collection_S2_beta/collection_LULC_S2_beta');

// 3. MÁSCARA DE VEGETAÇÃO NATIVA (2008 e 2022) 
var nativeClasses = [3, 4, 5, 11, 12, 32];

var mask08 = col9.select('classification_2008').clip(para)
  .remap(nativeClasses, ee.List.repeat(1, nativeClasses.length), 0).rename('veg_2008');

var mask22 = col10.select('classification_2022').clip(para)
  .remap(nativeClasses, ee.List.repeat(1, nativeClasses.length), 0).rename('veg_2022');

// Integração das bandas para processamento único
var multitemporal = mask08.addBands(mask22);

// 4. CÁLCULO ZONAL (Soma de pixels convertida para hectares)
var stats = multitemporal.multiply(ee.Image.pixelArea()).divide(10000).reduceRegions({
  collection: car,
  reducer: ee.Reducer.sum(),
  scale: 30 
});

// 5. SIMULAÇÃO DE CENÁRIOS E CORREÇÃO DE TIPOS [cite: 22, 100]
var resultados = stats.map(function(f) {
  // Conversão de String (padrão BR com vírgula) para Number para cálculos matemáticos
  var areaStr = ee.String(f.get('num_area_i')); 
  var areaTotal = ee.Number.parse(areaStr.replace(',', '.'));
  
  var veg08 = ee.Number(f.get('veg_2008')); 
  var veg22 = ee.Number(f.get('veg_2022')); 
  
  // Identificação do Passivo Não Consolidado (Supressão após 22/07/2008) [cite: 72]
  var supressaoPos2008 = veg08.subtract(veg22).max(0);
  
  // Cenário A: Exigência Padrão de 80% (Reserva Legal na Amazônia) [cite: 68]
  var rl80 = areaTotal.multiply(0.8);
  var deficit80 = rl80.subtract(veg22).max(0);
  
  // Cenário B: Redução para 50% (Artigo 12 da Lei 12.651/2012) [cite: 11, 100]
  var rl50 = areaTotal.multiply(0.5);
  var deficit50 = rl50.subtract(veg22).max(0);
  
  // Delta: Área que atinge a conformidade ambiental via redução [cite: 22]
  var delta = deficit80.subtract(deficit50);
  
  // Lógica condicional para identificar imóveis beneficiados
  var statusBeneficio = ee.Algorithms.If(delta.gt(0), 'Sim', 'Não');
  
  return f.set({
    'area_ha': areaTotal,
    'veg08_ha': veg08,
    'veg22_ha': veg22,
    'pass_n_con': supressaoPos2008,
    'def_80_ha': deficit80,
    'def_50_ha': deficit50,
    'delta_reg': delta,
    'beneficia': statusBeneficio
  });
});

// 6. EXPORTAÇÃO (CSV para análise estatística externa) [cite: 23]
Export.table.toDrive({
  collection: resultados,
  description: 'Impacto_Reducao_RL_Para_Acima_4MF',
  fileFormat: 'CSV',
  selectors: ['codigo_car', 'municipio', 'area_ha', 'veg08_ha', 'veg22_ha', 'pass_n_con', 'def_80_ha', 'def_50_ha', 'delta_reg', 'beneficia']
});

// 7. VISUALIZAÇÃO [cite: 44, 46]
Map.centerObject(car, 6);
Map.addLayer(mask08.updateMask(mask08), {palette: 'green'}, 'Vegetação Nativa 2008 (Marco Legal)');
Map.addLayer(mask22.updateMask(mask22), {palette: '006400'}, 'Vegetação Nativa 2022');
Map.addLayer(car, {color: 'red'}, 'Imóveis > 4MF Analisados');