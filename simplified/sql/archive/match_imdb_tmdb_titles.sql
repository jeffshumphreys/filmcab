drop table if exists receiving_dock.imdb_flat_data;
select 
	ttl.imdb_tt_id, /* convert to int? */  
	ttl.title_type /* to enum */, 
	                                          ttl.primary_title, 
	nullif(ttl.original_title, ttl.primary_title) original_title
, pttl.primary_title                              parent_primary_title
, nullif(pttl.original_title, pttl.primary_title) parent_original_title
, pttl.title_type                                 parent_title_type
, ida01.title aka_title_01--, ida01.region_code  aka_region_code_01, ida01.language_code aka_language_code_01, ida01.types_of_title types_of_title_01, ida01.attributes_of_title attributes_of_title_01, ida01.is_original_title is_original_title_01
, ida02.title aka_title_02--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ida03.title aka_title_03--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ida04.title aka_title_04--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ida05.title aka_title_05--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ida06.title aka_title_06--, ida06.region_code  aka_region_code_06, ida06.language_code aka_language_code_06, ida06.types_of_title types_of_title_06, ida06.attributes_of_title attributes_of_title_06, ida06.is_original_title is_original_title_06
, ida07.title aka_title_07--, ida07.region_code  aka_region_code_07, ida07.language_code aka_language_code_07, ida07.types_of_title types_of_title_07, ida07.attributes_of_title attributes_of_title_07, ida07.is_original_title is_original_title_07
, ida08.title aka_title_08--, ida08.region_code  aka_region_code_08, ida08.language_code aka_language_code_08, ida08.types_of_title types_of_title_08, ida08.attributes_of_title attributes_of_title_08, ida08.is_original_title is_original_title_08
, ida09.title aka_title_09--, ida09.region_code  aka_region_code_09, ida09.language_code aka_language_code_09, ida09.types_of_title types_of_title_09, ida09.attributes_of_title attributes_of_title_09, ida09.is_original_title is_original_title_09
, ida10.title aka_title_10--, ida10.region_code  aka_region_code_10, ida10.language_code aka_language_code_10, ida10.types_of_title types_of_title_10, ida10.attributes_of_title attributes_of_title_10, ida10.is_original_title is_original_title_10
, ida11.title aka_title_11--, ida11.region_code  aka_region_code_11, ida11.language_code aka_language_code_11, ida11.types_of_title types_of_title_11, ida11.attributes_of_title attributes_of_title_11, ida11.is_original_title is_original_title_11
, ida12.title aka_title_12--, ida12.region_code  aka_region_code_12, ida12.language_code aka_language_code_12, ida12.types_of_title types_of_title_12, ida12.attributes_of_title attributes_of_title_12, ida12.is_original_title is_original_title_12
, ida13.title aka_title_13--, ida13.region_code  aka_region_code_13, ida13.language_code aka_language_code_13, ida13.types_of_title types_of_title_13, ida13.attributes_of_title attributes_of_title_13, ida13.is_original_title is_original_title_13
, ida14.title aka_title_14--, ida14.region_code  aka_region_code_14, ida14.language_code aka_language_code_14, ida14.types_of_title types_of_title_14, ida14.attributes_of_title attributes_of_title_14, ida14.is_original_title is_original_title_14
, ida15.title aka_title_15--, ida15.region_code  aka_region_code_15, ida15.language_code aka_language_code_15, ida15.types_of_title types_of_title_15, ida15.attributes_of_title attributes_of_title_15, ida15.is_original_title is_original_title_15
, ida16.title aka_title_16--, ida16.region_code  aka_region_code_16, ida16.language_code aka_language_code_16, ida16.types_of_title types_of_title_16, ida16.attributes_of_title attributes_of_title_16, ida16.is_original_title is_original_title_16
, ida17.title aka_title_17--, ida17.region_code  aka_region_code_17, ida17.language_code aka_language_code_17, ida17.types_of_title types_of_title_17, ida17.attributes_of_title attributes_of_title_17, ida17.is_original_title is_original_title_17
, ida18.title aka_title_18--, ida18.region_code  aka_region_code_18, ida18.language_code aka_language_code_18, ida18.types_of_title types_of_title_18, ida18.attributes_of_title attributes_of_title_18, ida18.is_original_title is_original_title_18
, ida19.title aka_title_19--, ida19.region_code  aka_region_code_19, ida19.language_code aka_language_code_19, ida19.types_of_title types_of_title_19, ida19.attributes_of_title attributes_of_title_19, ida19.is_original_title is_original_title_19
, ida20.title aka_title_20--, ida20.region_code  aka_region_code_20, ida20.language_code aka_language_code_20, ida20.types_of_title types_of_title_20, ida20.attributes_of_title attributes_of_title_20, ida20.is_original_title is_original_title_20
, ida21.title aka_title_21--, ida21.region_code  aka_region_code_21, ida21.language_code aka_language_code_21, ida21.types_of_title types_of_title_21, ida21.attributes_of_title attributes_of_title_21, ida21.is_original_title is_original_title_21
, ida22.title aka_title_22--, ida22.region_code  aka_region_code_22, ida22.language_code aka_language_code_22, ida22.types_of_title types_of_title_22, ida22.attributes_of_title attributes_of_title_22, ida22.is_original_title is_original_title_22
, ida23.title aka_title_23--, ida23.region_code  aka_region_code_23, ida23.language_code aka_language_code_23, ida23.types_of_title types_of_title_23, ida23.attributes_of_title attributes_of_title_23, ida23.is_original_title is_original_title_23
, ida24.title aka_title_24--, ida24.region_code  aka_region_code_24, ida24.language_code aka_language_code_24, ida24.types_of_title types_of_title_24, ida24.attributes_of_title attributes_of_title_24, ida24.is_original_title is_original_title_24
, ida25.title aka_title_25--, ida25.region_code  aka_region_code_25, ida25.language_code aka_language_code_25, ida25.types_of_title types_of_title_25, ida25.attributes_of_title attributes_of_title_25, ida25.is_original_title is_original_title_25
, ida26.title aka_title_26--, ida26.region_code  aka_region_code_26, ida26.language_code aka_language_code_26, ida26.types_of_title types_of_title_26, ida26.attributes_of_title attributes_of_title_26, ida26.is_original_title is_original_title_26
, ida27.title aka_title_27--, ida27.region_code  aka_region_code_27, ida27.language_code aka_language_code_27, ida27.types_of_title types_of_title_27, ida27.attributes_of_title attributes_of_title_27, ida27.is_original_title is_original_title_27
, ida28.title aka_title_28--, ida28.region_code  aka_region_code_28, ida28.language_code aka_language_code_28, ida28.types_of_title types_of_title_28, ida28.attributes_of_title attributes_of_title_28, ida28.is_original_title is_original_title_28
, ida29.title aka_title_29--, ida29.region_code  aka_region_code_29, ida29.language_code aka_language_code_29, ida29.types_of_title types_of_title_29, ida29.attributes_of_title attributes_of_title_29, ida29.is_original_title is_original_title_29
, ida30.title aka_title_30--, ida30.region_code  aka_region_code_30, ida30.language_code aka_language_code_30, ida30.types_of_title types_of_title_30, ida30.attributes_of_title attributes_of_title_30, ida30.is_original_title is_original_title_30
, ida31.title aka_title_31--, ida31.region_code  aka_region_code_31, ida31.language_code aka_language_code_31, ida31.types_of_title types_of_title_31, ida31.attributes_of_title attributes_of_title_31, ida31.is_original_title is_original_title_31
, ida32.title aka_title_32--, ida32.region_code  aka_region_code_32, ida32.language_code aka_language_code_32, ida32.types_of_title types_of_title_32, ida32.attributes_of_title attributes_of_title_32, ida32.is_original_title is_original_title_32
, ida33.title aka_title_33--, ida33.region_code  aka_region_code_33, ida33.language_code aka_language_code_33, ida33.types_of_title types_of_title_33, ida33.attributes_of_title attributes_of_title_33, ida33.is_original_title is_original_title_33
, ida34.title aka_title_34--, ida34.region_code  aka_region_code_34, ida34.language_code aka_language_code_34, ida34.types_of_title types_of_title_34, ida34.attributes_of_title attributes_of_title_34, ida34.is_original_title is_original_title_34
, ida35.title aka_title_35--, ida35.region_code  aka_region_code_35, ida35.language_code aka_language_code_35, ida35.types_of_title types_of_title_35, ida35.attributes_of_title attributes_of_title_35, ida35.is_original_title is_original_title_35
, ida36.title aka_title_36--, ida36.region_code  aka_region_code_36, ida36.language_code aka_language_code_36, ida36.types_of_title types_of_title_36, ida36.attributes_of_title attributes_of_title_36, ida36.is_original_title is_original_title_36
, ida37.title aka_title_37--, ida37.region_code  aka_region_code_37, ida37.language_code aka_language_code_37, ida37.types_of_title types_of_title_37, ida37.attributes_of_title attributes_of_title_37, ida37.is_original_title is_original_title_37
, ida38.title aka_title_38--, ida38.region_code  aka_region_code_38, ida38.language_code aka_language_code_38, ida38.types_of_title types_of_title_38, ida38.attributes_of_title attributes_of_title_38, ida38.is_original_title is_original_title_38
, ida39.title aka_title_39--, ida39.region_code  aka_region_code_39, ida39.language_code aka_language_code_39, ida39.types_of_title types_of_title_39, ida39.attributes_of_title attributes_of_title_39, ida39.is_original_title is_original_title_39
, ida40.title aka_title_40--, ida40.region_code  aka_region_code_40, ida40.language_code aka_language_code_40, ida40.types_of_title types_of_title_40, ida40.attributes_of_title attributes_of_title_40, ida40.is_original_title is_original_title_40
, ida41.title aka_title_41--, ida41.region_code  aka_region_code_41, ida41.language_code aka_language_code_41, ida41.types_of_title types_of_title_41, ida41.attributes_of_title attributes_of_title_41, ida41.is_original_title is_original_title_41
, ida42.title aka_title_42--, ida42.region_code  aka_region_code_42, ida42.language_code aka_language_code_42, ida42.types_of_title types_of_title_42, ida42.attributes_of_title attributes_of_title_42, ida42.is_original_title is_original_title_42
, ida43.title aka_title_43--, ida43.region_code  aka_region_code_43, ida43.language_code aka_language_code_43, ida43.types_of_title types_of_title_43, ida43.attributes_of_title attributes_of_title_43, ida43.is_original_title is_original_title_43
, ida44.title aka_title_44--, ida44.region_code  aka_region_code_44, ida44.language_code aka_language_code_44, ida44.types_of_title types_of_title_44, ida44.attributes_of_title attributes_of_title_44, ida44.is_original_title is_original_title_44
, ida45.title aka_title_45--, ida45.region_code  aka_region_code_45, ida45.language_code aka_language_code_45, ida45.types_of_title types_of_title_45, ida45.attributes_of_title attributes_of_title_45, ida45.is_original_title is_original_title_45
, ida46.title aka_title_46--, ida46.region_code  aka_region_code_46, ida46.language_code aka_language_code_46, ida46.types_of_title types_of_title_46, ida46.attributes_of_title attributes_of_title_46, ida46.is_original_title is_original_title_46
, ida47.title aka_title_47--, ida47.region_code  aka_region_code_47, ida47.language_code aka_language_code_47, ida47.types_of_title types_of_title_47, ida47.attributes_of_title attributes_of_title_47, ida47.is_original_title is_original_title_47
, ida48.title aka_title_48--, ida48.region_code  aka_region_code_48, ida48.language_code aka_language_code_48, ida48.types_of_title types_of_title_48, ida48.attributes_of_title attributes_of_title_48, ida48.is_original_title is_original_title_48
, ida49.title aka_title_49--, ida49.region_code  aka_region_code_49, ida49.language_code aka_language_code_49, ida49.types_of_title types_of_title_49, ida49.attributes_of_title attributes_of_title_49, ida49.is_original_title is_original_title_49
, ida50.title aka_title_50--, ida50.region_code  aka_region_code_50, ida50.language_code aka_language_code_50, ida50.types_of_title types_of_title_50, ida50.attributes_of_title attributes_of_title_50, ida50.is_original_title is_original_title_50
, ida51.title aka_title_51--, ida51.region_code  aka_region_code_51, ida51.language_code aka_language_code_51, ida51.types_of_title types_of_title_51, ida51.attributes_of_title attributes_of_title_51, ida51.is_original_title is_original_title_51
, ida52.title aka_title_52--, ida52.region_code  aka_region_code_52, ida52.language_code aka_language_code_52, ida52.types_of_title types_of_title_52, ida52.attributes_of_title attributes_of_title_52, ida52.is_original_title is_original_title_52
, ida53.title aka_title_53--, ida53.region_code  aka_region_code_53, ida53.language_code aka_language_code_53, ida53.types_of_title types_of_title_53, ida53.attributes_of_title attributes_of_title_53, ida53.is_original_title is_original_title_53
, ida54.title aka_title_54--, ida54.region_code  aka_region_code_54, ida54.language_code aka_language_code_54, ida54.types_of_title types_of_title_54, ida54.attributes_of_title attributes_of_title_54, ida54.is_original_title is_original_title_54
, ida55.title aka_title_55--, ida55.region_code  aka_region_code_55, ida55.language_code aka_language_code_55, ida55.types_of_title types_of_title_55, ida55.attributes_of_title attributes_of_title_55, ida55.is_original_title is_original_title_55
, ida56.title aka_title_56--, ida56.region_code  aka_region_code_56, ida56.language_code aka_language_code_56, ida56.types_of_title types_of_title_56, ida56.attributes_of_title attributes_of_title_56, ida56.is_original_title is_original_title_56
, ida57.title aka_title_57--, ida57.region_code  aka_region_code_57, ida57.language_code aka_language_code_57, ida57.types_of_title types_of_title_57, ida57.attributes_of_title attributes_of_title_57, ida57.is_original_title is_original_title_57
, ida58.title aka_title_58--, ida58.region_code  aka_region_code_58, ida58.language_code aka_language_code_58, ida58.types_of_title types_of_title_58, ida58.attributes_of_title attributes_of_title_58, ida58.is_original_title is_original_title_58
, ida59.title aka_title_59--, ida59.region_code  aka_region_code_59, ida59.language_code aka_language_code_59, ida59.types_of_title types_of_title_59, ida59.attributes_of_title attributes_of_title_59, ida59.is_original_title is_original_title_59
, ida60.title aka_title_60--, ida60.region_code  aka_region_code_60, ida60.language_code aka_language_code_60, ida60.types_of_title types_of_title_60, ida60.attributes_of_title attributes_of_title_60, ida60.is_original_title is_original_title_60
, ida61.title aka_title_61--, ida61.region_code  aka_region_code_61, ida61.language_code aka_language_code_61, ida61.types_of_title types_of_title_61, ida61.attributes_of_title attributes_of_title_61, ida61.is_original_title is_original_title_61
, ida62.title aka_title_62--, ida62.region_code  aka_region_code_62, ida62.language_code aka_language_code_62, ida62.types_of_title types_of_title_62, ida62.attributes_of_title attributes_of_title_62, ida62.is_original_title is_original_title_62
, ida63.title aka_title_63--, ida63.region_code  aka_region_code_63, ida63.language_code aka_language_code_63, ida63.types_of_title types_of_title_63, ida63.attributes_of_title attributes_of_title_63, ida63.is_original_title is_original_title_63
, ida64.title aka_title_64--, ida64.region_code  aka_region_code_64, ida64.language_code aka_language_code_64, ida64.types_of_title types_of_title_64, ida64.attributes_of_title attributes_of_title_64, ida64.is_original_title is_original_title_64
, ida65.title aka_title_65--, ida65.region_code  aka_region_code_65, ida65.language_code aka_language_code_65, ida65.types_of_title types_of_title_65, ida65.attributes_of_title attributes_of_title_65, ida65.is_original_title is_original_title_65
, ida66.title aka_title_66--, ida66.region_code  aka_region_code_66, ida66.language_code aka_language_code_66, ida66.types_of_title types_of_title_66, ida66.attributes_of_title attributes_of_title_66, ida66.is_original_title is_original_title_66
, ida67.title aka_title_67--, ida67.region_code  aka_region_code_67, ida67.language_code aka_language_code_67, ida67.types_of_title types_of_title_67, ida67.attributes_of_title attributes_of_title_67, ida67.is_original_title is_original_title_67
, ida68.title aka_title_68--, ida68.region_code  aka_region_code_68, ida68.language_code aka_language_code_68, ida68.types_of_title types_of_title_68, ida68.attributes_of_title attributes_of_title_68, ida68.is_original_title is_original_title_68
, ida69.title aka_title_69--, ida69.region_code  aka_region_code_69, ida69.language_code aka_language_code_69, ida69.types_of_title types_of_title_69, ida69.attributes_of_title attributes_of_title_69, ida69.is_original_title is_original_title_69
, ida70.title aka_title_70--, ida70.region_code  aka_region_code_70, ida70.language_code aka_language_code_70, ida70.types_of_title types_of_title_70, ida70.attributes_of_title attributes_of_title_70, ida70.is_original_title is_original_title_70
, ida71.title aka_title_71--, ida71.region_code  aka_region_code_71, ida71.language_code aka_language_code_71, ida71.types_of_title types_of_title_71, ida71.attributes_of_title attributes_of_title_71, ida71.is_original_title is_original_title_71
, ida72.title aka_title_72--, ida72.region_code  aka_region_code_72, ida72.language_code aka_language_code_72, ida72.types_of_title types_of_title_72, ida72.attributes_of_title attributes_of_title_72, ida72.is_original_title is_original_title_72
, ida73.title aka_title_73--, ida73.region_code  aka_region_code_73, ida73.language_code aka_language_code_73, ida73.types_of_title types_of_title_73, ida73.attributes_of_title attributes_of_title_73, ida73.is_original_title is_original_title_73
, ida74.title aka_title_74--, ida74.region_code  aka_region_code_74, ida74.language_code aka_language_code_74, ida74.types_of_title types_of_title_74, ida74.attributes_of_title attributes_of_title_74, ida74.is_original_title is_original_title_74
, ida75.title aka_title_75--, ida75.region_code  aka_region_code_75, ida75.language_code aka_language_code_75, ida75.types_of_title types_of_title_75, ida75.attributes_of_title attributes_of_title_75, ida75.is_original_title is_original_title_75
, ida76.title aka_title_76--, ida76.region_code  aka_region_code_76, ida76.language_code aka_language_code_76, ida76.types_of_title types_of_title_76, ida76.attributes_of_title attributes_of_title_76, ida76.is_original_title is_original_title_76
, ida77.title aka_title_77--, ida77.region_code  aka_region_code_77, ida77.language_code aka_language_code_77, ida77.types_of_title types_of_title_77, ida77.attributes_of_title attributes_of_title_77, ida77.is_original_title is_original_title_77
, ida78.title aka_title_78--, ida78.region_code  aka_region_code_78, ida78.language_code aka_language_code_78, ida78.types_of_title types_of_title_78, ida78.attributes_of_title attributes_of_title_78, ida78.is_original_title is_original_title_78
, ida79.title aka_title_79--, ida79.region_code  aka_region_code_79, ida79.language_code aka_language_code_79, ida79.types_of_title types_of_title_79, ida79.attributes_of_title attributes_of_title_79, ida79.is_original_title is_original_title_79
, ida80.title aka_title_80--, ida80.region_code  aka_region_code_80, ida80.language_code aka_language_code_80, ida80.types_of_title types_of_title_80, ida80.attributes_of_title attributes_of_title_80, ida80.is_original_title is_original_title_80
, ida81.title aka_title_81--, ida81.region_code  aka_region_code_81, ida81.language_code aka_language_code_81, ida81.types_of_title types_of_title_81, ida81.attributes_of_title attributes_of_title_81, ida81.is_original_title is_original_title_81
, ida82.title aka_title_82--, ida82.region_code  aka_region_code_82, ida82.language_code aka_language_code_82, ida82.types_of_title types_of_title_82, ida82.attributes_of_title attributes_of_title_82, ida82.is_original_title is_original_title_82
, ida83.title aka_title_83--, ida83.region_code  aka_region_code_83, ida83.language_code aka_language_code_83, ida83.types_of_title types_of_title_83, ida83.attributes_of_title attributes_of_title_83, ida83.is_original_title is_original_title_83
, ida84.title aka_title_84--, ida84.region_code  aka_region_code_84, ida84.language_code aka_language_code_84, ida84.types_of_title types_of_title_84, ida84.attributes_of_title attributes_of_title_84, ida84.is_original_title is_original_title_84
, ida85.title aka_title_85--, ida85.region_code  aka_region_code_85, ida85.language_code aka_language_code_85, ida85.types_of_title types_of_title_85, ida85.attributes_of_title attributes_of_title_85, ida85.is_original_title is_original_title_85
, ida86.title aka_title_86--, ida86.region_code  aka_region_code_86, ida86.language_code aka_language_code_86, ida86.types_of_title types_of_title_86, ida86.attributes_of_title attributes_of_title_86, ida86.is_original_title is_original_title_86
, ida87.title aka_title_87--, ida87.region_code  aka_region_code_87, ida87.language_code aka_language_code_87, ida87.types_of_title types_of_title_87, ida87.attributes_of_title attributes_of_title_87, ida87.is_original_title is_original_title_87
, ida88.title aka_title_88--, ida88.region_code  aka_region_code_88, ida88.language_code aka_language_code_88, ida88.types_of_title types_of_title_88, ida88.attributes_of_title attributes_of_title_88, ida88.is_original_title is_original_title_88
, ida89.title aka_title_89--, ida89.region_code  aka_region_code_89, ida89.language_code aka_language_code_89, ida89.types_of_title types_of_title_89, ida89.attributes_of_title attributes_of_title_89, ida89.is_original_title is_original_title_89
, ida90.title aka_title_90--, ida90.region_code  aka_region_code_90, ida90.language_code aka_language_code_90, ida90.types_of_title types_of_title_90, ida90.attributes_of_title attributes_of_title_90, ida90.is_original_title is_original_title_90
, ida91.title aka_title_91--, ida91.region_code  aka_region_code_91, ida91.language_code aka_language_code_91, ida91.types_of_title types_of_title_91, ida91.attributes_of_title attributes_of_title_91, ida91.is_original_title is_original_title_91
, ida92.title aka_title_92--, ida92.region_code  aka_region_code_92, ida92.language_code aka_language_code_92, ida92.types_of_title types_of_title_92, ida92.attributes_of_title attributes_of_title_92, ida92.is_original_title is_original_title_92
, ida93.title aka_title_93--, ida93.region_code  aka_region_code_93, ida93.language_code aka_language_code_93, ida93.types_of_title types_of_title_93, ida93.attributes_of_title attributes_of_title_93, ida93.is_original_title is_original_title_93
, ida94.title aka_title_94--, ida94.region_code  aka_region_code_94, ida94.language_code aka_language_code_94, ida94.types_of_title types_of_title_94, ida94.attributes_of_title attributes_of_title_94, ida94.is_original_title is_original_title_94
, ida95.title aka_title_95--, ida95.region_code  aka_region_code_95, ida95.language_code aka_language_code_95, ida95.types_of_title types_of_title_95, ida95.attributes_of_title attributes_of_title_95, ida95.is_original_title is_original_title_95
, ida96.title aka_title_96--, ida96.region_code  aka_region_code_96, ida96.language_code aka_language_code_96, ida96.types_of_title types_of_title_96, ida96.attributes_of_title attributes_of_title_96, ida96.is_original_title is_original_title_96
, ida97.title aka_title_97--, ida97.region_code  aka_region_code_97, ida97.language_code aka_language_code_97, ida97.types_of_title types_of_title_97, ida97.attributes_of_title attributes_of_title_97, ida97.is_original_title is_original_title_97
, ida98.title aka_title_98--, ida98.region_code  aka_region_code_98, ida98.language_code aka_language_code_98, ida98.types_of_title types_of_title_98, ida98.attributes_of_title attributes_of_title_98, ida98.is_original_title is_original_title_98
, ida99.title aka_title_99--, ida99.region_code  aka_region_code_99, ida99.language_code aka_language_code_99, ida99.types_of_title types_of_title_99, ida99.attributes_of_title attributes_of_title_99, ida99.is_original_title is_original_title_99
, ttl.start_year, ttl.end_year, ttl.runtime_minutes 
, ttl.is_adult
, string_to_array(ttl.genres, ',') as genres
, string_to_array(idtc.directors_imdb_nm_ids, ',') as directors_imdb_nm_ids
, string_to_array(idtc.writers_imdb_nm_ids, ',')   as writers_imdb_nm_ids
, idnb01.person_name principal01
, idtr.average_rating, idtr.num_votes
, idte.season_no, idte.episode_no
, idte.parent_imdb_tt_id 
into receiving_dock.imdb_flat_data
from receiving_dock.imdb_data_title_basics ttl 
left join receiving_dock.imdb_data_title_crew idtc on ttl.imdb_tt_id  = idtc.imdb_tt_id 
left join receiving_dock.imdb_data_title_ratings idtr on ttl.imdb_tt_id = idtr.imdb_tt_id 
left join receiving_dock.imdb_data_title_episode idte on ttl.imdb_tt_id = idte.imdb_tt_id 
left join receiving_dock.imdb_data_title_basics pttl on idte.parent_imdb_tt_id = pttl.imdb_tt_id 
left join receiving_dock.imdb_data_title_akas ida01 on ttl.imdb_tt_id = ida01.imdb_tt_id and ida01.ordering_no = '1' 
left join receiving_dock.imdb_data_title_akas ida02 on ttl.imdb_tt_id = ida02.imdb_tt_id and ida02.ordering_no = '2' 
left join receiving_dock.imdb_data_title_akas ida03 on ttl.imdb_tt_id = ida03.imdb_tt_id and ida03.ordering_no = '3' 
left join receiving_dock.imdb_data_title_akas ida04 on ttl.imdb_tt_id = ida04.imdb_tt_id and ida04.ordering_no = '4' 
left join receiving_dock.imdb_data_title_akas ida05 on ttl.imdb_tt_id = ida05.imdb_tt_id and ida05.ordering_no = '5' 
left join receiving_dock.imdb_data_title_akas ida06 on ttl.imdb_tt_id = ida06.imdb_tt_id and ida06.ordering_no = '6'
left join receiving_dock.imdb_data_title_akas ida07 on ttl.imdb_tt_id = ida07.imdb_tt_id and ida07.ordering_no = '7'
left join receiving_dock.imdb_data_title_akas ida08 on ttl.imdb_tt_id = ida08.imdb_tt_id and ida08.ordering_no = '8'
left join receiving_dock.imdb_data_title_akas ida09 on ttl.imdb_tt_id = ida09.imdb_tt_id and ida09.ordering_no = '9'
left join receiving_dock.imdb_data_title_akas ida10 on ttl.imdb_tt_id = ida10.imdb_tt_id and ida10.ordering_no = '10'
left join receiving_dock.imdb_data_title_akas ida11 on ttl.imdb_tt_id = ida11.imdb_tt_id and ida11.ordering_no = '11'
left join receiving_dock.imdb_data_title_akas ida12 on ttl.imdb_tt_id = ida12.imdb_tt_id and ida12.ordering_no = '12'
left join receiving_dock.imdb_data_title_akas ida13 on ttl.imdb_tt_id = ida13.imdb_tt_id and ida13.ordering_no = '13'
left join receiving_dock.imdb_data_title_akas ida14 on ttl.imdb_tt_id = ida14.imdb_tt_id and ida14.ordering_no = '14'
left join receiving_dock.imdb_data_title_akas ida15 on ttl.imdb_tt_id = ida15.imdb_tt_id and ida15.ordering_no = '15'
left join receiving_dock.imdb_data_title_akas ida16 on ttl.imdb_tt_id = ida16.imdb_tt_id and ida16.ordering_no = '16'
left join receiving_dock.imdb_data_title_akas ida17 on ttl.imdb_tt_id = ida17.imdb_tt_id and ida17.ordering_no = '17'
left join receiving_dock.imdb_data_title_akas ida18 on ttl.imdb_tt_id = ida18.imdb_tt_id and ida18.ordering_no = '18'
left join receiving_dock.imdb_data_title_akas ida19 on ttl.imdb_tt_id = ida19.imdb_tt_id and ida19.ordering_no = '19'
left join receiving_dock.imdb_data_title_akas ida20 on ttl.imdb_tt_id = ida20.imdb_tt_id and ida20.ordering_no = '20'
left join receiving_dock.imdb_data_title_akas ida21 on ttl.imdb_tt_id = ida21.imdb_tt_id and ida21.ordering_no = '21'
left join receiving_dock.imdb_data_title_akas ida22 on ttl.imdb_tt_id = ida22.imdb_tt_id and ida22.ordering_no = '22'
left join receiving_dock.imdb_data_title_akas ida23 on ttl.imdb_tt_id = ida23.imdb_tt_id and ida23.ordering_no = '23'
left join receiving_dock.imdb_data_title_akas ida24 on ttl.imdb_tt_id = ida24.imdb_tt_id and ida24.ordering_no = '24'
left join receiving_dock.imdb_data_title_akas ida25 on ttl.imdb_tt_id = ida25.imdb_tt_id and ida25.ordering_no = '25'
left join receiving_dock.imdb_data_title_akas ida26 on ttl.imdb_tt_id = ida26.imdb_tt_id and ida26.ordering_no = '26'
left join receiving_dock.imdb_data_title_akas ida27 on ttl.imdb_tt_id = ida27.imdb_tt_id and ida27.ordering_no = '27'
left join receiving_dock.imdb_data_title_akas ida28 on ttl.imdb_tt_id = ida28.imdb_tt_id and ida28.ordering_no = '28'
left join receiving_dock.imdb_data_title_akas ida29 on ttl.imdb_tt_id = ida29.imdb_tt_id and ida29.ordering_no = '29'
left join receiving_dock.imdb_data_title_akas ida30 on ttl.imdb_tt_id = ida30.imdb_tt_id and ida30.ordering_no = '30'
left join receiving_dock.imdb_data_title_akas ida31 on ttl.imdb_tt_id = ida31.imdb_tt_id and ida31.ordering_no = '31'
left join receiving_dock.imdb_data_title_akas ida32 on ttl.imdb_tt_id = ida32.imdb_tt_id and ida32.ordering_no = '32'
left join receiving_dock.imdb_data_title_akas ida33 on ttl.imdb_tt_id = ida33.imdb_tt_id and ida33.ordering_no = '33'
left join receiving_dock.imdb_data_title_akas ida34 on ttl.imdb_tt_id = ida34.imdb_tt_id and ida34.ordering_no = '34'
left join receiving_dock.imdb_data_title_akas ida35 on ttl.imdb_tt_id = ida35.imdb_tt_id and ida35.ordering_no = '35'
left join receiving_dock.imdb_data_title_akas ida36 on ttl.imdb_tt_id = ida36.imdb_tt_id and ida36.ordering_no = '36'
left join receiving_dock.imdb_data_title_akas ida37 on ttl.imdb_tt_id = ida37.imdb_tt_id and ida37.ordering_no = '37'
left join receiving_dock.imdb_data_title_akas ida38 on ttl.imdb_tt_id = ida38.imdb_tt_id and ida38.ordering_no = '38'
left join receiving_dock.imdb_data_title_akas ida39 on ttl.imdb_tt_id = ida39.imdb_tt_id and ida39.ordering_no = '39'
left join receiving_dock.imdb_data_title_akas ida40 on ttl.imdb_tt_id = ida40.imdb_tt_id and ida40.ordering_no = '40'
left join receiving_dock.imdb_data_title_akas ida41 on ttl.imdb_tt_id = ida41.imdb_tt_id and ida41.ordering_no = '41'
left join receiving_dock.imdb_data_title_akas ida42 on ttl.imdb_tt_id = ida42.imdb_tt_id and ida42.ordering_no = '42'
left join receiving_dock.imdb_data_title_akas ida43 on ttl.imdb_tt_id = ida43.imdb_tt_id and ida43.ordering_no = '43'
left join receiving_dock.imdb_data_title_akas ida44 on ttl.imdb_tt_id = ida44.imdb_tt_id and ida44.ordering_no = '44'
left join receiving_dock.imdb_data_title_akas ida45 on ttl.imdb_tt_id = ida45.imdb_tt_id and ida45.ordering_no = '45'
left join receiving_dock.imdb_data_title_akas ida46 on ttl.imdb_tt_id = ida46.imdb_tt_id and ida46.ordering_no = '46'
left join receiving_dock.imdb_data_title_akas ida47 on ttl.imdb_tt_id = ida47.imdb_tt_id and ida47.ordering_no = '47'
left join receiving_dock.imdb_data_title_akas ida48 on ttl.imdb_tt_id = ida48.imdb_tt_id and ida48.ordering_no = '48'
left join receiving_dock.imdb_data_title_akas ida49 on ttl.imdb_tt_id = ida49.imdb_tt_id and ida49.ordering_no = '49'
left join receiving_dock.imdb_data_title_akas ida50 on ttl.imdb_tt_id = ida50.imdb_tt_id and ida50.ordering_no = '50'
left join receiving_dock.imdb_data_title_akas ida51 on ttl.imdb_tt_id = ida51.imdb_tt_id and ida51.ordering_no = '51'
left join receiving_dock.imdb_data_title_akas ida52 on ttl.imdb_tt_id = ida52.imdb_tt_id and ida52.ordering_no = '52'
left join receiving_dock.imdb_data_title_akas ida53 on ttl.imdb_tt_id = ida53.imdb_tt_id and ida53.ordering_no = '53'
left join receiving_dock.imdb_data_title_akas ida54 on ttl.imdb_tt_id = ida54.imdb_tt_id and ida54.ordering_no = '54'
left join receiving_dock.imdb_data_title_akas ida55 on ttl.imdb_tt_id = ida55.imdb_tt_id and ida55.ordering_no = '55'
left join receiving_dock.imdb_data_title_akas ida56 on ttl.imdb_tt_id = ida56.imdb_tt_id and ida56.ordering_no = '56'
left join receiving_dock.imdb_data_title_akas ida57 on ttl.imdb_tt_id = ida57.imdb_tt_id and ida57.ordering_no = '57'
left join receiving_dock.imdb_data_title_akas ida58 on ttl.imdb_tt_id = ida58.imdb_tt_id and ida58.ordering_no = '58'
left join receiving_dock.imdb_data_title_akas ida59 on ttl.imdb_tt_id = ida59.imdb_tt_id and ida59.ordering_no = '59'
left join receiving_dock.imdb_data_title_akas ida60 on ttl.imdb_tt_id = ida60.imdb_tt_id and ida60.ordering_no = '60'
left join receiving_dock.imdb_data_title_akas ida61 on ttl.imdb_tt_id = ida61.imdb_tt_id and ida61.ordering_no = '61'
left join receiving_dock.imdb_data_title_akas ida62 on ttl.imdb_tt_id = ida62.imdb_tt_id and ida62.ordering_no = '62'
left join receiving_dock.imdb_data_title_akas ida63 on ttl.imdb_tt_id = ida63.imdb_tt_id and ida63.ordering_no = '63'
left join receiving_dock.imdb_data_title_akas ida64 on ttl.imdb_tt_id = ida64.imdb_tt_id and ida64.ordering_no = '64'
left join receiving_dock.imdb_data_title_akas ida65 on ttl.imdb_tt_id = ida65.imdb_tt_id and ida65.ordering_no = '65'
left join receiving_dock.imdb_data_title_akas ida66 on ttl.imdb_tt_id = ida66.imdb_tt_id and ida66.ordering_no = '66'
left join receiving_dock.imdb_data_title_akas ida67 on ttl.imdb_tt_id = ida67.imdb_tt_id and ida67.ordering_no = '67'
left join receiving_dock.imdb_data_title_akas ida68 on ttl.imdb_tt_id = ida68.imdb_tt_id and ida68.ordering_no = '68'
left join receiving_dock.imdb_data_title_akas ida69 on ttl.imdb_tt_id = ida69.imdb_tt_id and ida69.ordering_no = '69'
left join receiving_dock.imdb_data_title_akas ida70 on ttl.imdb_tt_id = ida70.imdb_tt_id and ida70.ordering_no = '70'
left join receiving_dock.imdb_data_title_akas ida71 on ttl.imdb_tt_id = ida71.imdb_tt_id and ida71.ordering_no = '71'
left join receiving_dock.imdb_data_title_akas ida72 on ttl.imdb_tt_id = ida72.imdb_tt_id and ida72.ordering_no = '72'
left join receiving_dock.imdb_data_title_akas ida73 on ttl.imdb_tt_id = ida73.imdb_tt_id and ida73.ordering_no = '73'
left join receiving_dock.imdb_data_title_akas ida74 on ttl.imdb_tt_id = ida74.imdb_tt_id and ida74.ordering_no = '74'
left join receiving_dock.imdb_data_title_akas ida75 on ttl.imdb_tt_id = ida75.imdb_tt_id and ida75.ordering_no = '75'
left join receiving_dock.imdb_data_title_akas ida76 on ttl.imdb_tt_id = ida76.imdb_tt_id and ida76.ordering_no = '76'
left join receiving_dock.imdb_data_title_akas ida77 on ttl.imdb_tt_id = ida77.imdb_tt_id and ida77.ordering_no = '77'
left join receiving_dock.imdb_data_title_akas ida78 on ttl.imdb_tt_id = ida78.imdb_tt_id and ida78.ordering_no = '78'
left join receiving_dock.imdb_data_title_akas ida79 on ttl.imdb_tt_id = ida79.imdb_tt_id and ida79.ordering_no = '79'
left join receiving_dock.imdb_data_title_akas ida80 on ttl.imdb_tt_id = ida80.imdb_tt_id and ida80.ordering_no = '80'
left join receiving_dock.imdb_data_title_akas ida81 on ttl.imdb_tt_id = ida81.imdb_tt_id and ida81.ordering_no = '81'
left join receiving_dock.imdb_data_title_akas ida82 on ttl.imdb_tt_id = ida82.imdb_tt_id and ida82.ordering_no = '82'
left join receiving_dock.imdb_data_title_akas ida83 on ttl.imdb_tt_id = ida83.imdb_tt_id and ida83.ordering_no = '83'
left join receiving_dock.imdb_data_title_akas ida84 on ttl.imdb_tt_id = ida84.imdb_tt_id and ida84.ordering_no = '84'
left join receiving_dock.imdb_data_title_akas ida85 on ttl.imdb_tt_id = ida85.imdb_tt_id and ida85.ordering_no = '85'
left join receiving_dock.imdb_data_title_akas ida86 on ttl.imdb_tt_id = ida86.imdb_tt_id and ida86.ordering_no = '86'
left join receiving_dock.imdb_data_title_akas ida87 on ttl.imdb_tt_id = ida87.imdb_tt_id and ida87.ordering_no = '87'
left join receiving_dock.imdb_data_title_akas ida88 on ttl.imdb_tt_id = ida88.imdb_tt_id and ida88.ordering_no = '88'
left join receiving_dock.imdb_data_title_akas ida89 on ttl.imdb_tt_id = ida89.imdb_tt_id and ida89.ordering_no = '89'
left join receiving_dock.imdb_data_title_akas ida90 on ttl.imdb_tt_id = ida90.imdb_tt_id and ida90.ordering_no = '90'
left join receiving_dock.imdb_data_title_akas ida91 on ttl.imdb_tt_id = ida91.imdb_tt_id and ida91.ordering_no = '91'
left join receiving_dock.imdb_data_title_akas ida92 on ttl.imdb_tt_id = ida92.imdb_tt_id and ida92.ordering_no = '92'
left join receiving_dock.imdb_data_title_akas ida93 on ttl.imdb_tt_id = ida93.imdb_tt_id and ida93.ordering_no = '93'
left join receiving_dock.imdb_data_title_akas ida94 on ttl.imdb_tt_id = ida94.imdb_tt_id and ida94.ordering_no = '94'
left join receiving_dock.imdb_data_title_akas ida95 on ttl.imdb_tt_id = ida95.imdb_tt_id and ida95.ordering_no = '95'
left join receiving_dock.imdb_data_title_akas ida96 on ttl.imdb_tt_id = ida96.imdb_tt_id and ida96.ordering_no = '96'
left join receiving_dock.imdb_data_title_akas ida97 on ttl.imdb_tt_id = ida97.imdb_tt_id and ida97.ordering_no = '97'
left join receiving_dock.imdb_data_title_akas ida98 on ttl.imdb_tt_id = ida98.imdb_tt_id and ida98.ordering_no = '98'
left join receiving_dock.imdb_data_title_akas ida99 on ttl.imdb_tt_id = ida99.imdb_tt_id and ida99.ordering_no = '99'
left join receiving_dock.imdb_data_title_principals idtp01 on ttl.imdb_tt_id = idtp01.imdb_tt_id and idtp01.ordering_no = '1'
left join receiving_dock.imdb_data_name_basics idnb01 on idtp01.imdb_nm_id = idnb01.imdb_nm_id
;
alter table receiving_dock.imdb_flat_data add constraint ak_imdb_id_flat unique(imdb_tt_id);
with r as (
select 
	x.imdb_tt_id                                    as imdb_id, 
	y.tmdb_id                                       as tmdb_id,
	x.primary_title                                 as imdb_title1,
	y.title                                         as tmdb_title1,
	convert_to_meaning_match(y.original_title, 'm') as tmdb_title2_norm,
	convert_to_meaning_match(x.primary_title , 'a') as imdb_title1_norm,
	convert_to_meaning_match(y.title         , 'h') as tmdb_title1_norm,
	convert_to_meaning_match(x.original_title, 'b') as imdb_title2_norm,
	convert_to_meaning_match(x.aka_title_01  , 'c') as imdb_title3_norm,
	convert_to_meaning_match(x.aka_title_02  , 'd') as imdb_title4_norm,
	convert_to_meaning_match(x.aka_title_03  , 'e') as imdb_title5_norm,
	convert_to_meaning_match(x.aka_title_04  , 'f') as imdb_title6_norm,
	convert_to_meaning_match(x.aka_title_05  , 'g') as imdb_title7_norm,
	convert_to_meaning_match(x.aka_title_06  , 'h') as imdb_title8_norm,
	convert_to_meaning_match(x.aka_title_07  , 'i') as imdb_title9_norm,
	convert_to_meaning_match(x.aka_title_08  , 'j') as imdb_title10_norm,
	convert_to_meaning_match(x.aka_title_09  , 'k') as imdb_title11_norm,
	convert_to_meaning_match(x.aka_title_10  , 'l') as imdb_title12_norm,
	convert_to_meaning_match(x.aka_title_11  , '11') as imdb_title13_norm,
	convert_to_meaning_match(x.aka_title_12  , '12') as imdb_title14_norm,
	convert_to_meaning_match(x.aka_title_13  , '13') as imdb_title15_norm,
	convert_to_meaning_match(x.aka_title_14  , '14') as imdb_title16_norm,
	convert_to_meaning_match(x.aka_title_15  , '15') as imdb_title17_norm,
	convert_to_meaning_match(x.aka_title_16  , '16') as imdb_title18_norm,
	convert_to_meaning_match(x.aka_title_17  , '17') as imdb_title19_norm,
	convert_to_meaning_match(x.aka_title_18  , '18') as imdb_title20_norm,
	convert_to_meaning_match(x.aka_title_19  , '19') as imdb_title21_norm,
	convert_to_meaning_match(x.aka_title_20  , '20') as imdb_title22_norm,
	convert_to_meaning_match(x.aka_title_21  , '21') as imdb_title23_norm,
	convert_to_meaning_match(x.aka_title_22  , '22') as imdb_title24_norm,
	convert_to_meaning_match(x.aka_title_23  , '23') as imdb_title25_norm,
	convert_to_meaning_match(x.aka_title_24  , '24') as imdb_title26_norm,
	convert_to_meaning_match(x.aka_title_25  , '25') as imdb_title27_norm,
	convert_to_meaning_match(x.aka_title_26  , '26') as imdb_title28_norm,
	convert_to_meaning_match(x.aka_title_27  , '27') as imdb_title29_norm,
	convert_to_meaning_match(x.aka_title_28  , '28') as imdb_title30_norm,
	convert_to_meaning_match(x.aka_title_29  , '29') as imdb_title31_norm,
	convert_to_meaning_match(x.aka_title_30  , '30') as imdb_title32_norm,
	convert_to_meaning_match(x.aka_title_31  , '31') as imdb_title33_norm,
	convert_to_meaning_match(x.aka_title_32  , '32') as imdb_title34_norm,
	convert_to_meaning_match(x.aka_title_33  , '33') as imdb_title35_norm,
	convert_to_meaning_match(x.aka_title_34  , '34') as imdb_title36_norm,
	convert_to_meaning_match(x.aka_title_35  , '35') as imdb_title37_norm,
	convert_to_meaning_match(x.aka_title_36  , '36') as imdb_title38_norm,
	convert_to_meaning_match(x.aka_title_37  , '37') as imdb_title39_norm,
	convert_to_meaning_match(x.aka_title_38  , '38') as imdb_title40_norm,
	convert_to_meaning_match(x.aka_title_39  , '39') as imdb_title41_norm,
	convert_to_meaning_match(x.aka_title_40  , '40') as imdb_title42_norm,
	convert_to_meaning_match(x.aka_title_41  , '41') as imdb_title43_norm,
	convert_to_meaning_match(x.aka_title_42  , '42') as imdb_title44_norm,
	convert_to_meaning_match(x.aka_title_43  , '43') as imdb_title45_norm,
	convert_to_meaning_match(x.aka_title_44  , '44') as imdb_title46_norm,
	convert_to_meaning_match(x.aka_title_45  , '45') as imdb_title47_norm,
	convert_to_meaning_match(x.aka_title_46  , '46') as imdb_title48_norm,
	convert_to_meaning_match(x.aka_title_47  , '47') as imdb_title49_norm,
	convert_to_meaning_match(x.aka_title_48  , '48') as imdb_title50_norm,
	convert_to_meaning_match(x.aka_title_49  , '49') as imdb_title51_norm,
	convert_to_meaning_match(x.aka_title_50  , '50') as imdb_title52_norm,
	convert_to_meaning_match(x.aka_title_51  , '51') as imdb_title53_norm,
	convert_to_meaning_match(x.aka_title_52  , '52') as imdb_title54_norm,
	convert_to_meaning_match(x.aka_title_53  , '53') as imdb_title55_norm,
	convert_to_meaning_match(x.aka_title_54  , '54') as imdb_title56_norm,
	convert_to_meaning_match(x.aka_title_55  , '55') as imdb_title57_norm,
	convert_to_meaning_match(x.aka_title_56  , '56') as imdb_title58_norm,
	convert_to_meaning_match(x.aka_title_57  , '57') as imdb_title59_norm,
	convert_to_meaning_match(x.aka_title_58  , '58') as imdb_title60_norm,
	convert_to_meaning_match(x.aka_title_59  , '59') as imdb_title61_norm,
	convert_to_meaning_match(x.aka_title_60  , '60') as imdb_title62_norm,
	convert_to_meaning_match(x.aka_title_61  , '61') as imdb_title63_norm,
	convert_to_meaning_match(x.aka_title_62  , '62') as imdb_title64_norm,
	convert_to_meaning_match(x.aka_title_63  , '63') as imdb_title65_norm,
	convert_to_meaning_match(x.aka_title_64  , '64') as imdb_title66_norm,
	convert_to_meaning_match(x.aka_title_65  , '65') as imdb_title67_norm,
	convert_to_meaning_match(x.aka_title_66  , '66') as imdb_title68_norm,
	convert_to_meaning_match(x.aka_title_67  , '67') as imdb_title69_norm,
	convert_to_meaning_match(x.aka_title_68  , '68') as imdb_title70_norm,
	convert_to_meaning_match(x.aka_title_69  , '69') as imdb_title71_norm,
	convert_to_meaning_match(x.aka_title_70  , '70') as imdb_title72_norm,
	convert_to_meaning_match(x.aka_title_71  , '71') as imdb_title73_norm,
	convert_to_meaning_match(x.aka_title_72  , '72') as imdb_title74_norm,
	convert_to_meaning_match(x.aka_title_73  , '73') as imdb_title75_norm,
	convert_to_meaning_match(x.aka_title_74  , '74') as imdb_title76_norm,
	convert_to_meaning_match(x.aka_title_75  , '75') as imdb_title77_norm,
	convert_to_meaning_match(x.aka_title_76  , '76') as imdb_title78_norm,
	convert_to_meaning_match(x.aka_title_77  , '77') as imdb_title79_norm,
	convert_to_meaning_match(x.aka_title_78  , '78') as imdb_title80_norm,
	convert_to_meaning_match(x.aka_title_79  , '79') as imdb_title81_norm,
	convert_to_meaning_match(x.aka_title_80  , '80') as imdb_title82_norm,
	convert_to_meaning_match(x.aka_title_81  , '81') as imdb_title83_norm,
	convert_to_meaning_match(x.aka_title_82  , '82') as imdb_title84_norm,
	convert_to_meaning_match(x.aka_title_83  , '83') as imdb_title85_norm,
	convert_to_meaning_match(x.aka_title_84  , '84') as imdb_title86_norm,
	convert_to_meaning_match(x.aka_title_85  , '85') as imdb_title87_norm,
	convert_to_meaning_match(x.aka_title_86  , '86') as imdb_title88_norm,
	convert_to_meaning_match(x.aka_title_87  , '87') as imdb_title89_norm,
	convert_to_meaning_match(x.aka_title_88  , '88') as imdb_title90_norm,
	convert_to_meaning_match(x.aka_title_89  , '89') as imdb_title91_norm,
	convert_to_meaning_match(x.aka_title_90  , '90') as imdb_title92_norm,
	convert_to_meaning_match(x.aka_title_91  , '91') as imdb_title93_norm,
	convert_to_meaning_match(x.aka_title_92  , '92') as imdb_title94_norm,
	convert_to_meaning_match(x.aka_title_93  , '93') as imdb_title95_norm,
	convert_to_meaning_match(x.aka_title_94  , '94') as imdb_title96_norm,
	convert_to_meaning_match(x.aka_title_95  , '95') as imdb_title97_norm,
	convert_to_meaning_match(x.aka_title_96  , '96') as imdb_title98_norm,
	convert_to_meaning_match(x.aka_title_97  , '97') as imdb_title99_norm,
	convert_to_meaning_match(x.aka_title_98  , '98') as imdb_title100_norm,
	convert_to_meaning_match(x.aka_title_99  , '99') as imdb_title101_norm,
	x.start_year                                    as imdb_release_year,                             
	left(y.release_date, 4)                         as tmdb_release_year,
	x.runtime_minutes                               as imdb_runtime,
	y.runtime                                       as tmdb_runtime,
	x.genres                                        as imdb_genres,
	string_to_array(y.genres, ',')                  as tmdb_genres,
	x.is_adult                                      as imdb_adult,
	y.adult::BOOLEAN                                as tmdb_adult,
	x.principal01                                   as imdb_principal1,
	clock_timestamp() as captured_on 
from receiving_dock.imdb_flat_data x 
join receiving_dock.video_data y on x.imdb_tt_id = y.imdb_tt_id 
) 
select 
    count(*) OVER()                                 as how_many_matches,
	*
into receiving_dock.imdb_tmdb_title_match_fails
from r
where tmdb_title1_norm not in(imdb_title1_norm, imdb_title2_norm, imdb_title3_norm, imdb_title4_norm, imdb_title5_norm, imdb_title6_norm,imdb_title7_norm,imdb_title8_norm,imdb_title9_norm,imdb_title10_norm,imdb_title11_norm,imdb_title12_norm,imdb_title13_norm,imdb_title14_norm,imdb_title15_norm,imdb_title16_norm,imdb_title17_norm,imdb_title18_norm,imdb_title19_norm,imdb_title20_norm,imdb_title21_norm,imdb_title22_norm,imdb_title23_norm,imdb_title24_norm,imdb_title25_norm,imdb_title26_norm,imdb_title27_norm,imdb_title28_norm,imdb_title29_norm,imdb_title30_norm,imdb_title31_norm,imdb_title32_norm,imdb_title33_norm,imdb_title34_norm,imdb_title35_norm,imdb_title36_norm,imdb_title37_norm,imdb_title38_norm,imdb_title39_norm,imdb_title40_norm,imdb_title41_norm,imdb_title42_norm,imdb_title43_norm,imdb_title44_norm,imdb_title45_norm,imdb_title46_norm,imdb_title47_norm,imdb_title48_norm,imdb_title49_norm,imdb_title50_norm,imdb_title51_norm,imdb_title52_norm,imdb_title53_norm,imdb_title54_norm,imdb_title55_norm,imdb_title56_norm,imdb_title57_norm,imdb_title58_norm,imdb_title59_norm,imdb_title60_norm,imdb_title61_norm,imdb_title62_norm,imdb_title63_norm,imdb_title64_norm,imdb_title65_norm,imdb_title66_norm,imdb_title67_norm,imdb_title68_norm,imdb_title69_norm,imdb_title70_norm,imdb_title71_norm,imdb_title72_norm,imdb_title73_norm,imdb_title74_norm,imdb_title75_norm,imdb_title76_norm,imdb_title77_norm,imdb_title78_norm,imdb_title79_norm,imdb_title80_norm,imdb_title81_norm,imdb_title82_norm,imdb_title83_norm,imdb_title84_norm,imdb_title85_norm,imdb_title86_norm,imdb_title87_norm,imdb_title88_norm,imdb_title89_norm,imdb_title90_norm,imdb_title91_norm,imdb_title92_norm,imdb_title93_norm,imdb_title94_norm,imdb_title95_norm,imdb_title96_norm,imdb_title97_norm,imdb_title98_norm,imdb_title99_norm)
and tmdb_title2_norm not in(imdb_title1_norm, imdb_title2_norm, imdb_title3_norm, imdb_title4_norm, imdb_title5_norm, imdb_title6_norm, imdb_title7_norm, imdb_title8_norm, imdb_title9_norm, imdb_title10_norm, imdb_title11_norm, imdb_title12_norm,imdb_title13_norm,imdb_title14_norm,imdb_title15_norm,imdb_title16_norm,imdb_title17_norm,imdb_title18_norm,imdb_title19_norm,imdb_title20_norm,imdb_title21_norm,imdb_title22_norm,imdb_title23_norm,imdb_title24_norm,imdb_title25_norm,imdb_title26_norm,imdb_title27_norm,imdb_title28_norm,imdb_title29_norm,imdb_title30_norm,imdb_title31_norm,imdb_title32_norm,imdb_title33_norm,imdb_title34_norm,imdb_title35_norm,imdb_title36_norm,imdb_title37_norm,imdb_title38_norm,imdb_title39_norm,imdb_title40_norm,imdb_title41_norm,imdb_title42_norm,imdb_title43_norm,imdb_title44_norm,imdb_title45_norm,imdb_title46_norm,imdb_title47_norm,imdb_title48_norm,imdb_title49_norm,imdb_title50_norm,imdb_title51_norm,imdb_title52_norm,imdb_title53_norm,imdb_title54_norm,imdb_title55_norm,imdb_title56_norm,imdb_title57_norm,imdb_title58_norm,imdb_title59_norm,imdb_title60_norm,imdb_title61_norm,imdb_title62_norm,imdb_title63_norm,imdb_title64_norm,imdb_title65_norm,imdb_title66_norm,imdb_title67_norm,imdb_title68_norm,imdb_title69_norm,imdb_title70_norm,imdb_title71_norm,imdb_title72_norm,imdb_title73_norm,imdb_title74_norm,imdb_title75_norm,imdb_title76_norm,imdb_title77_norm,imdb_title78_norm,imdb_title79_norm,imdb_title80_norm,imdb_title81_norm,imdb_title82_norm,imdb_title83_norm,imdb_title84_norm,imdb_title85_norm,imdb_title86_norm,imdb_title87_norm,imdb_title88_norm,imdb_title89_norm,imdb_title90_norm,imdb_title91_norm,imdb_title92_norm,imdb_title93_norm,imdb_title94_norm,imdb_title95_norm,imdb_title96_norm,imdb_title97_norm,imdb_title98_norm,imdb_title99_norm)
and tmdb_title1_norm not like '%' || imdb_title1_norm || '%' 
and imdb_title1_norm not like '%' || tmdb_title1_norm || '%' 
;

create or replace function convert_to_meaning_match(instring text, unique_dummy_char text) returns text language plpgsql stable as
$$
declare 
  r text;
  reducedinstring text;
  chars text[]; 
 regexes text[];
begin
    -- now clean up with some reg strings on word
	regexes := '{"\bthe\b", "\ba\b"}'; -- Third -> 3rd, ii -> 2, vol2$ -> 2$
	-- Order is important if spaces are part of the match
    chars := '{" and the "," and ", " the ", " a ", " ", ",", ":", "-", "''", "?", "!", "&", ".", "#", "@", "(", ")", "*", "~", "°", "/", "\", "^", "$"}';
    -- "2, 1, 0" = "twoonezeri"
    -- "bangboatvol5" = "bangboat5"
    -- "1000yearsleep" = "thousandyearsleep"
    -- "aagandhiaurtoofan" = "aagaandhiaurtoofan" strip double letters "aa" to "a"?
    -- "meatballs4" = "meatballsiv"
    -- "atriskoflife" = "attheriskoflife"
    -- One Way Passage to Death	= Modern Chivarly: Sworn Brothers same year, duration: possibly just two titles wildly different from each other.
    -- Extreme Championship Wrestling: Heatwave '98	= ECW Heat Wave 1998  An abbreviation, and a short year.  match "'nn" and expand?
  reducedinstring := '^' || lower(unaccent(instring)) '$';
  if reducedinstring is null then
  	return unique_dummy_char;
  end if;
  foreach r in array chars
  loop
  	reducedinstring := replace(reducedinstring, r, '');
  end loop;
  return reducedinstring;
end;
$$ 
;
select convert_to_meaning_match('Velvet Revolver: Live in Houston');

