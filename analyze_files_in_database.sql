select f.typ_id, max(t.txt) as typ_nm, COUNT(*) FROM stage_for_master.files f join public.typs t  on f.typ_id = t.id
group by f.typ_id ;
select f.txt, f.final_extension  from stage_for_master.files f where f.typ_id = 8 and f.file_md5_hash not in(
	select p.file_md5_hash from stage_for_master.files p where p.typ_id = 9) and f.final_extension not in('srt', 'sub', 'idx')
	and (f.file_deleted is null or f.file_deleted is false)
;
select f.txt, f.final_extension  from stage_for_master.files f where f.typ_id = 8 and f.file_md5_hash not in(
	select p.file_md5_hash from stage_for_master.files p where p.typ_id = 9)
-- https://www.venea.net/web/culture_code
-- French
and f.txt not like '%FRE.srt'
and f.txt not like '%.fre.srt'
and f.txt not like '%_fre.srt'
and f.txt not like '%.fra.srt'
and f.txt not like '%_fra.srt'
and f.txt not like '%-fra-%.srt'
and f.txt not like '%french.srt'
and f.txt not like '%French.srt'
-- Hungarian
and f.txt not like '%HUN.srt'
and f.txt not like '%-hun-%.srt'
and f.txt not like '%hungarian.srt'
-- Portugese
and f.txt not like '%Portuguese.srt'
and f.txt not like '%POR.srt'
and f.txt not like '%por.srt'
and f.txt not like '%ptb.srt'
and f.txt not like '%-por-%.srt'
-- Polish
and f.txt not like '%POL.srt'
-- Spanish
and f.txt not like '%.spa.srt'
and f.txt not like '%_spa.srt'
and f.txt not like '%SPA.srt'
and f.txt not like '%-spa-%.srt'
and f.txt not like '%spanish.srt'
and f.txt not like '%Spanish.srt'
and f.txt not like '%esp.srt'
and f.txt not like '%-est-%.srt'
and f.txt not like '%.ES.srt'
-- German
and f.txt not like '%GER.srt'
and f.txt not like '%ger.srt'
and f.txt not like '%-deu-%.srt'
-- Brazil
and f.txt not like '%brazil.srt'
-- Dutch
and f.txt not like '%DUT.srt'
and f.txt not like '%dut.srt'
and f.txt not like '%.nl.srt'
and f.txt not like '%dutch.srt'
-- Danish
and f.txt not like '%DAN.srt'
and f.txt not like '%dan.srt'
-- Finnish, Finland
and f.txt not like '%FIN.srt'
and f.txt not like '%fin.srt'
and f.txt not like '%-fin-%.srt'
-- Norwegian
and f.txt not like '%nor.srt'
-- Romanian
and f.txt not like '%.romanian.srt'
and f.txt not like '%/ROM.srt'
and f.txt not like '% RUM.srt' -- NOT STANDARD
and f.txt not like '%/rum.srt' -- NOT STANDARD
and f.txt not like '%.rum.srt' -- NOT STANDARD
-- Swedish
and f.txt not like '%swe.srt'
and f.txt not like '%SWE.srt'
and f.txt not like '%-swe-%.srt'
-- Italian
and f.txt not like '%ITA.srt'
and f.txt not like '%ita.srt'
and f.txt not like '%-it-%.srt'
and f.txt not like '%-ita-%.srt'
-- Russian
and f.txt not like '%RUS.srt'
and f.txt not like '%Russian.srt'
and f.txt not like '%russian.srt'
and f.txt not like '%-rus-%.srt'
-- Turkish
and f.txt not like '%turkish.srt'
and f.txt not like '%/TUR.srt'
-- Greek
and f.txt not like '%greek.srt'
and f.txt not like '%GRE.srt'
and f.txt not like '%.gre.srt'
and f.txt not like '%-el-%.srt'
and f.txt not like '%-ell-%.srt'
-- Slovencina
and f.txt not like '%.slo.srt'
-- Arabic
and f.txt not like '%arabic.srt'
and f.txt not like '%-ara-%.srt'
-- Japanese
and f.txt not like '%-ja-%.srt'
and f.txt not like '%-jpn-%.srt' -- Not a code
-- Chinese
and f.txt not like '%-zho-%.srt'
and f.txt not like '%.Chs.srt'
and f.txt not like '%.Cht.srt'
and f.txt not like '%.chi.srt'
and f.txt not like '%-hant-%.srt'
-- Hebrew
and f.txt not like '%-he-%.srt'
and f.txt not like '%-heb-%.srt'
-- Czech
and f.txt not like '%-ces-%.srt'
and f.txt not like '%.cze.srt' -- Non standard.
and f.txt not like '%/CZE.srt' -- Non standard.
-- Indian
and f.txt not like '%-ind-%.srt'
-- Hindi
and f.txt not like '%-hin-%.srt'
-- Croatian
and f.txt not like '%-hrv-%.srt'
-- Persian
and f.txt not like '%-fas-%.srt'
and f.txt not like '%.persian.srt'
-- Bulgarian
and f.txt not like '%-bul-%.srt'
-- Icelandic
and f.txt not like '%-isl-%.srt'
-- Korean
and f.txt not like '%-kor-%.srt'
-- Malay
and f.txt not like '%-msa-%.srt'
and f.txt not like '%.may.srt' -- NOT STANDARD
-- 2 char
and f.txt not like '%-af-%.srt' -- Afrikaans
and f.txt not like '%-af-ZA-%.srt' -- Afrikaans (South Africa)
and f.txt not like '%-am-%.srt' -- Amharic
and f.txt not like '%-am-ET-%.srt' -- Amharic (Ethiopia)
and f.txt not like '%-ar-%.srt' -- Arabic
and f.txt not like '%-ar-AE-%.srt' -- Arabic (U.A.E.)
and f.txt not like '%-ar-BH-%.srt' -- Arabic (Bahrain)
and f.txt not like '%-ar-DZ-%.srt' -- Arabic (Algeria)
and f.txt not like '%-ar-EG-%.srt' -- Arabic (Egypt)
and f.txt not like '%-ar-IQ-%.srt' -- Arabic (Iraq)
and f.txt not like '%-ar-JO-%.srt' -- Arabic (Jordan)
and f.txt not like '%-ar-KW-%.srt' -- Arabic (Kuwait)
and f.txt not like '%-ar-LB-%.srt' -- Arabic (Lebanon)
and f.txt not like '%-ar-LY-%.srt' -- Arabic (Libya)
and f.txt not like '%-ar-MA-%.srt' -- Arabic (Morocco)
and f.txt not like '%-ar-OM-%.srt' -- Arabic (Oman)
and f.txt not like '%-ar-QA-%.srt' -- Arabic (Qatar)
and f.txt not like '%-ar-SA-%.srt' -- Arabic (Saudi Arabia)
and f.txt not like '%-ar-SY-%.srt' -- Arabic (Syria)
and f.txt not like '%-ar-TN-%.srt' -- Arabic (Tunisia)
and f.txt not like '%-ar-YE-%.srt' -- Arabic (Yemen)
and f.txt not like '%-arn-%.srt' -- Mapudungun
and f.txt not like '%-arn-CL-%.srt' -- Mapudungun (Chile)
and f.txt not like '%-as-%.srt' -- Assamese
and f.txt not like '%-as-IN-%.srt' -- Assamese (India)
and f.txt not like '%-az-%.srt' -- Azerbaijani
and f.txt not like '%-az-Cyrl-%.srt' -- Azerbaijani (Cyrillic)
and f.txt not like '%-az-Cyrl-AZ-%.srt' -- Azerbaijani (Cyrillic), (Azerbaijan)
and f.txt not like '%-az-Latn-%.srt' -- Azerbaijani (Latin)
and f.txt not like '%-az-Latn-AZ-%.srt' -- Azerbaijani (Latin), (Azerbaijan)
and f.txt not like '%-ba-%.srt' -- Bashkir
and f.txt not like '%-ba-RU-%.srt' -- Bashkir (Russia)
and f.txt not like '%-be-%.srt' -- Belarusian
and f.txt not like '%-be-BY-%.srt' -- Belarusian (Belarus)
and f.txt not like '%-bg-%.srt' -- Bulgarian
and f.txt not like '%-bg-BG-%.srt' -- Bulgarian (Bulgaria)
and f.txt not like '%-bn-%.srt' -- Bangla
and f.txt not like '%-bn-BD-%.srt' -- Bangla (Bangladesh)
and f.txt not like '%-bn-IN-%.srt' -- Bangla (India)
and f.txt not like '%-bo-%.srt' -- Tibetan
and f.txt not like '%-bo-CN-%.srt' -- Tibetan (China)
and f.txt not like '%-br-%.srt' -- Breton
and f.txt not like '%-br-FR-%.srt' -- Breton (France)
and f.txt not like '%-bs-%.srt' -- Bosnian
and f.txt not like '%-bs-Cyrl-%.srt' -- Bosnian (Cyrillic)
and f.txt not like '%-bs-Cyrl-BA-%.srt' -- Bosnian (Cyrillic), (Bosnia and Herzegovina)
and f.txt not like '%-bs-Latn-%.srt' -- Bosnian (Latin)
and f.txt not like '%-bs-Latn-BA-%.srt' -- Bosnian (Latin), (Bosnia and Herzegovina)
and f.txt not like '%-ca-%.srt' -- Catalan
and f.txt not like '%-ca-ES-%.srt' -- Catalan (Catalan)
and f.txt not like '%-ca-ES-valencia-%.srt' -- Valencian (Spain)
and f.txt not like '%-chr-%.srt' -- Cherokee
and f.txt not like '%-chr-Cher-%.srt' -- Cherokee
and f.txt not like '%-chr-Cher-US-%.srt' -- Cherokee (Cherokee)
and f.txt not like '%-co-%.srt' -- Corsican
and f.txt not like '%-co-FR-%.srt' -- Corsican (France)
and f.txt not like '%-cs-%.srt' -- Czech
and f.txt not like '%-cs-CZ-%.srt' -- Czech (Czech Republic)
and f.txt not like '%-cy-%.srt' -- Welsh
and f.txt not like '%-cy-GB-%.srt' -- Welsh (United Kingdom)
and f.txt not like '%-da-%.srt' -- Danish
and f.txt not like '%-da-DK-%.srt' -- Danish (Denmark)
and f.txt not like '%-de-%.srt' -- German
and f.txt not like '%-de-AT-%.srt' -- German (Austria)
and f.txt not like '%-de-CH-%.srt' -- German (Switzerland)
and f.txt not like '%-de-DE-%.srt' -- German (Germany)
and f.txt not like '%-de-LI-%.srt' -- German (Liechtenstein)
and f.txt not like '%-de-LU-%.srt' -- German (Luxembourg)
and f.txt not like '%-dsb-%.srt' -- Lower Sorbian
and f.txt not like '%-dsb-DE-%.srt' -- Lower Sorbian (Germany)
and f.txt not like '%-dv-%.srt' -- Divehi
and f.txt not like '%-dv-MV-%.srt' -- Divehi (Maldives)
and f.txt not like '%-el-%.srt' -- Greek
and f.txt not like '%-el-GR-%.srt' -- Greek (Greece)
--and f.txt not like '%-en-%.srt' -- English
--and f.txt not like '%-en-029-%.srt' -- English (Caribbean)
--and f.txt not like '%-en-AU-%.srt' -- English (Australia)
--and f.txt not like '%-en-BZ-%.srt' -- English (Belize)
--and f.txt not like '%-en-CA-%.srt' -- English (Canada)
--and f.txt not like '%-en-GB-%.srt' -- English (United Kingdom)
--and f.txt not like '%-en-HK-%.srt' -- English (Hong Kong)
--and f.txt not like '%-en-IE-%.srt' -- English (Ireland)
--and f.txt not like '%-en-IN-%.srt' -- English (India)
--and f.txt not like '%-en-JM-%.srt' -- English (Jamaica)
--and f.txt not like '%-en-MY-%.srt' -- English (Malaysia)
--and f.txt not like '%-en-NZ-%.srt' -- English (New Zealand)
--and f.txt not like '%-en-PH-%.srt' -- English (Philippines)
--and f.txt not like '%-en-SG-%.srt' -- English (Singapore)
--and f.txt not like '%-en-TT-%.srt' -- English (Trinidad and Tobago)
--and f.txt not like '%-en-US-%.srt' -- English (United States)
--and f.txt not like '%-en-ZA-%.srt' -- English (South Africa)
--and f.txt not like '%-en-ZW-%.srt' -- English (Zimbabwe)
and f.txt not like '%-es-%.srt' -- Spanish
and f.txt not like '%-es-419-%.srt' -- Spanish (Latin America)
and f.txt not like '%-es-AR-%.srt' -- Spanish (Argentina)
and f.txt not like '%-es-BO-%.srt' -- Spanish (Bolivia)
and f.txt not like '%-es-CL-%.srt' -- Spanish (Chile)
and f.txt not like '%-es-CO-%.srt' -- Spanish (Colombia)
and f.txt not like '%-es-CR-%.srt' -- Spanish (Costa Rica)
and f.txt not like '%-es-DO-%.srt' -- Spanish (Dominican Republic)
and f.txt not like '%-es-EC-%.srt' -- Spanish (Ecuador)
and f.txt not like '%-es-ES-%.srt' -- Spanish (Spain), (International Sort)
and f.txt not like '%-es-GT-%.srt' -- Spanish (Guatemala)
and f.txt not like '%-es-HN-%.srt' -- Spanish (Honduras)
and f.txt not like '%-es-MX-%.srt' -- Spanish (Mexico)
and f.txt not like '%-es-NI-%.srt' -- Spanish (Nicaragua)
and f.txt not like '%-es-PA-%.srt' -- Spanish (Panama)
and f.txt not like '%-es-PE-%.srt' -- Spanish (Peru)
and f.txt not like '%-es-PR-%.srt' -- Spanish (Puerto Rico)
and f.txt not like '%-es-PY-%.srt' -- Spanish (Paraguay)
and f.txt not like '%-es-SV-%.srt' -- Spanish (El Salvador)
and f.txt not like '%-es-US-%.srt' -- Spanish (United States)
and f.txt not like '%-es-UY-%.srt' -- Spanish (Uruguay)
and f.txt not like '%-es-VE-%.srt' -- Spanish (Bolivarian Republic of Venezuela)
and f.txt not like '%-et-%.srt' -- Estonian
and f.txt not like '%-et-EE-%.srt' -- Estonian (Estonia)
and f.txt not like '%-eu-%.srt' -- Basque
and f.txt not like '%-eu-ES-%.srt' -- Basque (Basque)
and f.txt not like '%-fa-%.srt' -- Persian
and f.txt not like '%-fa-IR-%.srt' -- Persian
and f.txt not like '%-ff-%.srt' -- Fulah
and f.txt not like '%-ff-Latn-%.srt' -- Fulah
and f.txt not like '%-ff-Latn-SN-%.srt' -- Fulah (Latin), (Senegal)
and f.txt not like '%-fi-%.srt' -- Finnish
and f.txt not like '%-fi-FI-%.srt' -- Finnish (Finland)
and f.txt not like '%-fil-%.srt' -- Filipino
and f.txt not like '%-fil-PH-%.srt' -- Filipino (Philippines)
and f.txt not like '%-fo-%.srt' -- Faroese
and f.txt not like '%-fo-FO-%.srt' -- Faroese (Faroe Islands)
and f.txt not like '%-fr-%.srt' -- French
and f.txt not like '%-fr-BE-%.srt' -- French (Belgium)
and f.txt not like '%-fr-CA-%.srt' -- French (Canada)
and f.txt not like '%-fr-CD-%.srt' -- French (Congo [DRC])
and f.txt not like '%-fr-CH-%.srt' -- French (Switzerland)
and f.txt not like '%-fr-CI-%.srt' -- French (Ivory Coast)
and f.txt not like '%-fr-CM-%.srt' -- French (Cameroon)
and f.txt not like '%-fr-FR-%.srt' -- French (France)
and f.txt not like '%-fr-HT-%.srt' -- French (Haiti)
and f.txt not like '%-fr-LU-%.srt' -- French (Luxembourg)
and f.txt not like '%-fr-MA-%.srt' -- French (Morocco)
and f.txt not like '%-fr-MC-%.srt' -- French (Monaco)
and f.txt not like '%-fr-ML-%.srt' -- French (Mali)
and f.txt not like '%-fr-RE-%.srt' -- French (Réunion)
and f.txt not like '%-fr-SN-%.srt' -- French (Senegal)
and f.txt not like '%-fy-%.srt' -- Frisian
and f.txt not like '%-fy-NL-%.srt' -- Frisian (Netherlands)
and f.txt not like '%-ga-%.srt' -- Irish
and f.txt not like '%-ga-IE-%.srt' -- Irish (Ireland)
and f.txt not like '%-gd-%.srt' -- Scottish Gaelic
and f.txt not like '%-gd-GB-%.srt' -- Scottish Gaelic (United Kingdom)
and f.txt not like '%-gl-%.srt' -- Galician
and f.txt not like '%-gl-ES-%.srt' -- Galician (Galician)
and f.txt not like '%-gn-%.srt' -- Guarani
and f.txt not like '%-gn-PY-%.srt' -- Guarani (Paraguay)
and f.txt not like '%-gsw-%.srt' -- Alsatian
and f.txt not like '%-gsw-FR-%.srt' -- Alsatian (France)
and f.txt not like '%-gu-%.srt' -- Gujarati
and f.txt not like '%-gu-IN-%.srt' -- Gujarati (India)
and f.txt not like '%-ha-%.srt' -- Hausa
and f.txt not like '%-ha-Latn-%.srt' -- Hausa (Latin)
and f.txt not like '%-ha-Latn-NG-%.srt' -- Hausa (Latin), (Nigeria)
and f.txt not like '%-haw-%.srt' -- Hawaiian
and f.txt not like '%-haw-US-%.srt' -- Hawaiian (United States)
and f.txt not like '%-he-%.srt' -- Hebrew
and f.txt not like '%-he-IL-%.srt' -- Hebrew (Israel)
and f.txt not like '%-hi-%.srt' -- Hindi
and f.txt not like '%-hi-IN-%.srt' -- Hindi (India)
and f.txt not like '%-hr-%.srt' -- Croatian
and f.txt not like '%-hr-BA-%.srt' -- Croatian (Latin), (Bosnia and Herzegovina)
and f.txt not like '%-hr-HR-%.srt' -- Croatian (Croatia)
and f.txt not like '%-hsb-%.srt' -- Upper Sorbian
and f.txt not like '%-hsb-DE-%.srt' -- Upper Sorbian (Germany)
and f.txt not like '%-hu-%.srt' -- Hungarian
and f.txt not like '%-hu-HU-%.srt' -- Hungarian (Hungary)
and f.txt not like '%-hy-%.srt' -- Armenian
and f.txt not like '%-hy-AM-%.srt' -- Armenian (Armenia)
and f.txt not like '%-id-%.srt' -- Indonesian
and f.txt not like '%-id-ID-%.srt' -- Indonesian (Indonesia)
and f.txt not like '%-ig-%.srt' -- Igbo
and f.txt not like '%-ig-NG-%.srt' -- Igbo (Nigeria)
and f.txt not like '%-ii-%.srt' -- Yi
and f.txt not like '%-ii-CN-%.srt' -- Yi (China)
and f.txt not like '%-is-%.srt' -- Icelandic
and f.txt not like '%-is-IS-%.srt' -- Icelandic (Iceland)
and f.txt not like '%-it-%.srt' -- Italian
and f.txt not like '%-it-CH-%.srt' -- Italian (Switzerland)
and f.txt not like '%-it-IT-%.srt' -- Italian (Italy)
and f.txt not like '%-iu-%.srt' -- Inuktitut
and f.txt not like '%-iu-Cans-%.srt' -- Inuktitut (Syllabics)
and f.txt not like '%-iu-Cans-CA-%.srt' -- Inuktitut (Syllabics), (Canada)
and f.txt not like '%-iu-Latn-%.srt' -- Inuktitut (Latin)
and f.txt not like '%-iu-Latn-CA-%.srt' -- Inuktitut (Latin), (Canada)
and f.txt not like '%-ja-%.srt' -- Japanese
and f.txt not like '%-ja-JP-%.srt' -- Japanese (Japan)
and f.txt not like '%-jv-%.srt' -- Javanese
and f.txt not like '%-jv-Latn-%.srt' -- Javanese
and f.txt not like '%-jv-Latn-ID-%.srt' -- Javanese (Indonesia)
and f.txt not like '%-ka-%.srt' -- Georgian
and f.txt not like '%-ka-GE-%.srt' -- Georgian (Georgia)
and f.txt not like '%-kk-%.srt' -- Kazakh
and f.txt not like '%-kk-KZ-%.srt' -- Kazakh (Kazakhstan)
and f.txt not like '%-kl-%.srt' -- Greenlandic
and f.txt not like '%-kl-GL-%.srt' -- Greenlandic (Greenland)
and f.txt not like '%-km-%.srt' -- Khmer
and f.txt not like '%-km-KH-%.srt' -- Khmer (Cambodia)
and f.txt not like '%-kn-%.srt' -- Kannada
and f.txt not like '%-kn-IN-%.srt' -- Kannada (India)
and f.txt not like '%-ko-%.srt' -- Korean
and f.txt not like '%-ko-KR-%.srt' -- Korean (Korea)
and f.txt not like '%-kok-%.srt' -- Konkani
and f.txt not like '%-kok-IN-%.srt' -- Konkani (India)
and f.txt not like '%-ku-%.srt' -- Central Kurdish
and f.txt not like '%-ku-Arab-%.srt' -- Central Kurdish
and f.txt not like '%-ku-Arab-IQ-%.srt' -- Central Kurdish (Iraq)
and f.txt not like '%-ky-%.srt' -- Kyrgyz
and f.txt not like '%-ky-KG-%.srt' -- Kyrgyz (Kyrgyzstan)
and f.txt not like '%-lb-%.srt' -- Luxembourgish
and f.txt not like '%-lb-LU-%.srt' -- Luxembourgish (Luxembourg)
and f.txt not like '%-lo-%.srt' -- Lao
and f.txt not like '%-lo-LA-%.srt' -- Lao (Lao PDR)
and f.txt not like '%-lt-%.srt' -- Lithuanian
and f.txt not like '%-lt-LT-%.srt' -- Lithuanian (Lithuania)
and f.txt not like '%-lv-%.srt' -- Latvian
and f.txt not like '%-lv-LV-%.srt' -- Latvian (Latvia)
and f.txt not like '%-mg-%.srt' -- Malagasy
and f.txt not like '%-mg-MG-%.srt' -- Malagasy (Madagascar)
and f.txt not like '%-mi-%.srt' -- Maori
and f.txt not like '%-mi-NZ-%.srt' -- Maori (New Zealand)
and f.txt not like '%-mk-%.srt' -- Macedonian (Former Yugoslav Republic of Macedonia)
and f.txt not like '%-mk-MK-%.srt' -- Macedonian (Former Yugoslav Republic of Macedonia)
and f.txt not like '%-ml-%.srt' -- Malayalam
and f.txt not like '%-ml-IN-%.srt' -- Malayalam (India)
and f.txt not like '%-mn-%.srt' -- Mongolian
and f.txt not like '%-mn-Cyrl-%.srt' -- Mongolian (Cyrillic)
and f.txt not like '%-mn-MN-%.srt' -- Mongolian (Cyrillic), (Mongolia)
and f.txt not like '%-mn-Mong-%.srt' -- Mongolian (Traditional Mongolian)
and f.txt not like '%-mn-Mong-CN-%.srt' -- Mongolian (Traditional Mongolian), (China)
and f.txt not like '%-mn-Mong-MN-%.srt' -- Mongolian (Traditional Mongolian), (Mongolia)
and f.txt not like '%-moh-%.srt' -- Mohawk
and f.txt not like '%-moh-CA-%.srt' -- Mohawk (Mohawk)
and f.txt not like '%-mr-%.srt' -- Marathi
and f.txt not like '%-mr-IN-%.srt' -- Marathi (India)
and f.txt not like '%-ms-%.srt' -- Malay
and f.txt not like '%-ms-BN-%.srt' -- Malay (Brunei Darussalam)
and f.txt not like '%-ms-MY-%.srt' -- Malay (Malaysia)
and f.txt not like '%-mt-%.srt' -- Maltese
and f.txt not like '%-mt-MT-%.srt' -- Maltese (Malta)
and f.txt not like '%-my-%.srt' -- Burmese
and f.txt not like '%-my-MM-%.srt' -- Burmese (Myanmar)
and f.txt not like '%-nb-%.srt' -- Norwegian (Bokmål)
and f.txt not like '%-nb-NO-%.srt' -- Norwegian, Bokmål (Norway)
and f.txt not like '%-ne-%.srt' -- Nepali
and f.txt not like '%-ne-IN-%.srt' -- Nepali (India)
and f.txt not like '%-ne-NP-%.srt' -- Nepali (Nepal)
and f.txt not like '%-nl-%.srt' -- Dutch
and f.txt not like '%-nl-BE-%.srt' -- Dutch (Belgium)
and f.txt not like '%-nl-NL-%.srt' -- Dutch (Netherlands)
and f.txt not like '%-nn-%.srt' -- Norwegian (Nynorsk)
and f.txt not like '%-nn-NO-%.srt' -- Norwegian, Nynorsk (Norway)
and f.txt not like '%-no-%.srt' -- Norwegian
and f.txt not like '%-nqo-%.srt' -- N'ko
and f.txt not like '%-nqo-GN-%.srt' -- N'ko (Guinea)
and f.txt not like '%-nso-%.srt' -- Sesotho sa Leboa
and f.txt not like '%-nso-ZA-%.srt' -- Sesotho sa Leboa (South Africa)
and f.txt not like '%-oc-%.srt' -- Occitan
and f.txt not like '%-oc-FR-%.srt' -- Occitan (France)
and f.txt not like '%-om-%.srt' -- Oromo
and f.txt not like '%-om-ET-%.srt' -- Oromo (Ethiopia)
and f.txt not like '%-or-%.srt' -- Odia
and f.txt not like '%-or-IN-%.srt' -- Odia (India)
and f.txt not like '%-pa-%.srt' -- Punjabi
and f.txt not like '%-pa-Arab-%.srt' -- Punjabi
and f.txt not like '%-pa-Arab-PK-%.srt' -- Punjabi (Pakistan)
and f.txt not like '%-pa-IN-%.srt' -- Punjabi (India)
and f.txt not like '%-pl-%.srt' -- Polish
and f.txt not like '%-pl-PL-%.srt' -- Polish (Poland)
and f.txt not like '%-prs-%.srt' -- Dari
and f.txt not like '%-prs-AF-%.srt' -- Dari (Afghanistan)
and f.txt not like '%-ps-%.srt' -- Pashto
and f.txt not like '%-ps-AF-%.srt' -- Pashto (Afghanistan)
and f.txt not like '%-pt-%.srt' -- Portuguese
and f.txt not like '%-pt-AO-%.srt' -- Portuguese (Angola)
and f.txt not like '%-pt-BR-%.srt' -- Portuguese (Brazil)
and f.txt not like '%-pt-PT-%.srt' -- Portuguese (Portugal)
and f.txt not like '%-qut-%.srt' -- K'iche'
and f.txt not like '%-qut-GT-%.srt' -- K'iche' (Guatemala)
and f.txt not like '%-quz-%.srt' -- Quechua
and f.txt not like '%-quz-BO-%.srt' -- Quechua (Bolivia)
and f.txt not like '%-quz-EC-%.srt' -- Quichua (Ecuador)
and f.txt not like '%-quz-PE-%.srt' -- Quechua (Peru)
and f.txt not like '%-rm-%.srt' -- Romansh
and f.txt not like '%-rm-CH-%.srt' -- Romansh (Switzerland)
and f.txt not like '%-ro-%.srt' -- Romanian
and f.txt not like '%-ro-MD-%.srt' -- Romanian (Moldova)
and f.txt not like '%-ro-RO-%.srt' -- Romanian (Romania)
and f.txt not like '%-ru-%.srt' -- Russian
and f.txt not like '%-ru-RU-%.srt' -- Russian (Russia)
and f.txt not like '%-rw-%.srt' -- Kinyarwanda
and f.txt not like '%-rw-RW-%.srt' -- Kinyarwanda (Rwanda)
and f.txt not like '%-sa-%.srt' -- Sanskrit
and f.txt not like '%-sa-IN-%.srt' -- Sanskrit (India)
and f.txt not like '%-sah-%.srt' -- Sakha
and f.txt not like '%-sah-RU-%.srt' -- Sakha (Russia)
and f.txt not like '%-sd-%.srt' -- Sindhi
and f.txt not like '%-sd-Arab-%.srt' -- Sindhi
and f.txt not like '%-sd-Arab-PK-%.srt' -- Sindhi (Pakistan)
and f.txt not like '%-se-%.srt' -- Sami (Northern)
and f.txt not like '%-se-FI-%.srt' -- Sami, Northern (Finland)
and f.txt not like '%-se-NO-%.srt' -- Sami, Northern (Norway)
and f.txt not like '%-se-SE-%.srt' -- Sami, Northern (Sweden)
and f.txt not like '%-si-%.srt' -- Sinhala
and f.txt not like '%-si-LK-%.srt' -- Sinhala (Sri Lanka)
and f.txt not like '%-sk-%.srt' -- Slovak
and f.txt not like '%-sk-SK-%.srt' -- Slovak (Slovakia)
and f.txt not like '%-sl-%.srt' -- Slovenian
and f.txt not like '%-sl-SI-%.srt' -- Slovenian (Slovenia)
and f.txt not like '%-sma-%.srt' -- Sami (Southern)
and f.txt not like '%-sma-NO-%.srt' -- Sami, Southern (Norway)
and f.txt not like '%-sma-SE-%.srt' -- Sami, Southern (Sweden)
and f.txt not like '%-smj-%.srt' -- Sami (Lule)
and f.txt not like '%-smj-NO-%.srt' -- Sami, Lule (Norway)
and f.txt not like '%-smj-SE-%.srt' -- Sami, Lule (Sweden)
and f.txt not like '%-smn-%.srt' -- Sami (Inari)
and f.txt not like '%-smn-FI-%.srt' -- Sami, Inari (Finland)
and f.txt not like '%-sms-%.srt' -- Sami (Skolt)
and f.txt not like '%-sms-FI-%.srt' -- Sami, Skolt (Finland)
and f.txt not like '%-sn-%.srt' -- Shona
and f.txt not like '%-sn-Latn-%.srt' -- Shona (Latin)
and f.txt not like '%-sn-Latn-ZW-%.srt' -- Shona (Latin), (Zimbabwe)
and f.txt not like '%-so-%.srt' -- Somali
and f.txt not like '%-so-SO-%.srt' -- Somali (Somalia)
and f.txt not like '%-sq-%.srt' -- Albanian
and f.txt not like '%-sq-AL-%.srt' -- Albanian (Albania)
and f.txt not like '%-sr-%.srt' -- Serbian
and f.txt not like '%-sr-Cyrl-%.srt' -- Serbian (Cyrillic)
and f.txt not like '%-sr-Cyrl-BA-%.srt' -- Serbian (Cyrillic), (Bosnia and Herzegovina)
and f.txt not like '%-sr-Cyrl-CS-%.srt' -- Serbian (Cyrillic), (Serbia and Montenegro (Former))
and f.txt not like '%-sr-Cyrl-ME-%.srt' -- Serbian (Cyrillic), (Montenegro)
and f.txt not like '%-sr-Cyrl-RS-%.srt' -- Serbian (Cyrillic), (Serbia)
and f.txt not like '%-sr-Latn-%.srt' -- Serbian (Latin)
and f.txt not like '%-sr-Latn-BA-%.srt' -- Serbian (Latin), (Bosnia and Herzegovina)
and f.txt not like '%-sr-Latn-CS-%.srt' -- Serbian (Latin), (Serbia and Montenegro (Former))
and f.txt not like '%-sr-Latn-ME-%.srt' -- Serbian (Latin), (Montenegro)
and f.txt not like '%-sr-Latn-RS-%.srt' -- Serbian (Latin), (Serbia)
and f.txt not like '%-st-%.srt' -- Southern Sotho
and f.txt not like '%-st-ZA-%.srt' -- Southern Sotho (South Africa)
and f.txt not like '%-sv-%.srt' -- Swedish
and f.txt not like '%-sv-FI-%.srt' -- Swedish (Finland)
and f.txt not like '%-sv-SE-%.srt' -- Swedish (Sweden)
and f.txt not like '%-sw-%.srt' -- Kiswahili
and f.txt not like '%-sw-KE-%.srt' -- Kiswahili (Kenya)
and f.txt not like '%-syr-%.srt' -- Syriac
and f.txt not like '%-syr-SY-%.srt' -- Syriac (Syria)
and f.txt not like '%-ta-%.srt' -- Tamil
and f.txt not like '%-ta-IN-%.srt' -- Tamil (India)
and f.txt not like '%-ta-LK-%.srt' -- Tamil (Sri Lanka)
and f.txt not like '%-te-%.srt' -- Telugu
and f.txt not like '%-te-IN-%.srt' -- Telugu (India)
and f.txt not like '%-tg-%.srt' -- Tajik
and f.txt not like '%-tg-Cyrl-%.srt' -- Tajik (Cyrillic)
and f.txt not like '%-tg-Cyrl-TJ-%.srt' -- Tajik (Cyrillic), (Tajikistan)
and f.txt not like '%-th-%.srt' -- Thai
and f.txt not like '%-th-TH-%.srt' -- Thai (Thailand)
and f.txt not like '%-ti-%.srt' -- Tigrinya
and f.txt not like '%-ti-ER-%.srt' -- Tigrinya (Eritrea)
and f.txt not like '%-ti-ET-%.srt' -- Tigrinya (Ethiopia)
and f.txt not like '%-tk-%.srt' -- Turkmen
and f.txt not like '%-tk-TM-%.srt' -- Turkmen (Turkmenistan)
and f.txt not like '%-tn-%.srt' -- Setswana
and f.txt not like '%-tn-BW-%.srt' -- Setswana (Botswana)
and f.txt not like '%-tn-ZA-%.srt' -- Setswana (South Africa)
and f.txt not like '%-tr-%.srt' -- Turkish
and f.txt not like '%-tr-TR-%.srt' -- Turkish (Turkey)
and f.txt not like '%-ts-%.srt' -- Tsonga
and f.txt not like '%-ts-ZA-%.srt' -- Tsonga (South Africa)
and f.txt not like '%-tt-%.srt' -- Tatar
and f.txt not like '%-tt-RU-%.srt' -- Tatar (Russia)
and f.txt not like '%-tzm-%.srt' -- Tamazight
and f.txt not like '%-tzm-Latn-%.srt' -- Central Atlas Tamazight (Latin)
and f.txt not like '%-tzm-Latn-DZ-%.srt' -- Central Atlas Tamazight (Latin), (Algeria)
and f.txt not like '%-tzm-Tfng-%.srt' -- Central Atlas Tamazight (Tifinagh)
and f.txt not like '%-tzm-Tfng-MA-%.srt' -- Central Atlas Tamazight (Tifinagh), (Morocco)
and f.txt not like '%-ug-%.srt' -- Uyghur
and f.txt not like '%-ug-CN-%.srt' -- Uyghur (China)
and f.txt not like '%-uk-%.srt' -- Ukrainian
and f.txt not like '%-uk-UA-%.srt' -- Ukrainian (Ukraine)
and f.txt not like '%-ur-%.srt' -- Urdu
and f.txt not like '%-ur-IN-%.srt' -- Urdu (India)
and f.txt not like '%-ur-PK-%.srt' -- Urdu (Pakistan)
and f.txt not like '%-uz-%.srt' -- Uzbek
and f.txt not like '%-uz-Cyrl-%.srt' -- Uzbek (Cyrillic)
and f.txt not like '%-uz-Cyrl-UZ-%.srt' -- Uzbek (Cyrillic), (Uzbekistan)
and f.txt not like '%-uz-Latn-%.srt' -- Uzbek (Latin)
and f.txt not like '%-uz-Latn-UZ-%.srt' -- Uzbek (Latin), (Uzbekistan)
and f.txt not like '%-vi-%.srt' -- Vietnamese
and f.txt not like '%-vi-VN-%.srt' -- Vietnamese (Vietnam)
and f.txt not like '%-wo-%.srt' -- Wolof
and f.txt not like '%-wo-SN-%.srt' -- Wolof (Senegal)
and f.txt not like '%-xh-%.srt' -- isiXhosa
and f.txt not like '%-xh-ZA-%.srt' -- isiXhosa (South Africa)
and f.txt not like '%-yo-%.srt' -- Yoruba
and f.txt not like '%-yo-NG-%.srt' -- Yoruba (Nigeria)
and f.txt not like '%-zgh-%.srt' -- Standard Morrocan Tamazight
and f.txt not like '%-zgh-Tfng-%.srt' -- Standard Morrocan Tamazight (Tifinagh)
and f.txt not like '%-zgh-Tfng-MA-%.srt' -- Standard Morrocan Tamazight (Tifinagh), (Morocco)
and f.txt not like '%-zh-%.srt' -- Chinese
and f.txt not like '%-zh-CHS-%.srt' -- Chinese (Simplified) Legacy
and f.txt not like '%-zh-CHT-%.srt' -- Chinese (Traditional) Legacy
and f.txt not like '%-zh-CN-%.srt' -- Chinese (Simplified), (China)
and f.txt not like '%-zh-HK-%.srt' -- Chinese (Traditional), (Hong Kong SAR)
and f.txt not like '%-zh-Hans-%.srt' -- Chinese (Simplified)
and f.txt not like '%-zh-Hant-%.srt' -- Chinese (Traditional)
and f.txt not like '%-zh-MO-%.srt' -- Chinese (Traditional), (Macao SAR)
and f.txt not like '%-zh-SG-%.srt' -- Chinese (Simplified), (Singapore)
and f.txt not like '%-zh-TW-%.srt' -- Chinese (Traditional), (Taiwan)
and f.txt not like '%-zu-%.srt' -- isiZulu
and f.txt not like '%-zu-ZA-%.srt' -- isiZulu (South Africa)
and f.txt not like '%.afr.srt' -- Afrikaans
and f.txt not like '%.afr.srt' -- Afrikaans (South Africa)
and f.txt not like '%.amh.srt' -- Amharic
and f.txt not like '%.amh.srt' -- Amharic (Ethiopia)
and f.txt not like '%.ara.srt' -- Arabic
and f.txt not like '%.ara.srt' -- Arabic (U.A.E.)
and f.txt not like '%.ara.srt' -- Arabic (Bahrain)
and f.txt not like '%.ara.srt' -- Arabic (Algeria)
and f.txt not like '%.ara.srt' -- Arabic (Egypt)
and f.txt not like '%.ara.srt' -- Arabic (Iraq)
and f.txt not like '%.ara.srt' -- Arabic (Jordan)
and f.txt not like '%.ara.srt' -- Arabic (Kuwait)
and f.txt not like '%.ara.srt' -- Arabic (Lebanon)
and f.txt not like '%.ara.srt' -- Arabic (Libya)
and f.txt not like '%.ara.srt' -- Arabic (Morocco)
and f.txt not like '%.ara.srt' -- Arabic (Oman)
and f.txt not like '%.ara.srt' -- Arabic (Qatar)
and f.txt not like '%.ara.srt' -- Arabic (Saudi Arabia)
and f.txt not like '%.ara.srt' -- Arabic (Syria)
and f.txt not like '%.ara.srt' -- Arabic (Tunisia)
and f.txt not like '%.ara.srt' -- Arabic (Yemen)
and f.txt not like '%.arn.srt' -- Mapudungun
and f.txt not like '%.arn.srt' -- Mapudungun (Chile)
and f.txt not like '%.asm.srt' -- Assamese
and f.txt not like '%.asm.srt' -- Assamese (India)
and f.txt not like '%.aze.srt' -- Azerbaijani
and f.txt not like '%.aze.srt' -- Azerbaijani (Cyrillic)
and f.txt not like '%.aze.srt' -- Azerbaijani (Cyrillic), (Azerbaijan)
and f.txt not like '%.aze.srt' -- Azerbaijani (Latin)
and f.txt not like '%.aze.srt' -- Azerbaijani (Latin), (Azerbaijan)
and f.txt not like '%.bak.srt' -- Bashkir
and f.txt not like '%.bak.srt' -- Bashkir (Russia)
and f.txt not like '%.bel.srt' -- Belarusian
and f.txt not like '%.bel.srt' -- Belarusian (Belarus)
and f.txt not like '%.bul.srt' -- Bulgarian
and f.txt not like '%.bul.srt' -- Bulgarian (Bulgaria)
and f.txt not like '%.bng.srt' -- Bangla
and f.txt not like '%.bng.srt' -- Bangla (Bangladesh)
and f.txt not like '%.bng.srt' -- Bangla (India)
and f.txt not like '%.bod.srt' -- Tibetan
and f.txt not like '%.bod.srt' -- Tibetan (China)
and f.txt not like '%.bre.srt' -- Breton
and f.txt not like '%.bre.srt' -- Breton (France)
and f.txt not like '%.bsb.srt' -- Bosnian
and f.txt not like '%.bsc.srt' -- Bosnian (Cyrillic)
and f.txt not like '%.bsc.srt' -- Bosnian (Cyrillic), (Bosnia and Herzegovina)
and f.txt not like '%.bsb.srt' -- Bosnian (Latin)
and f.txt not like '%.bsb.srt' -- Bosnian (Latin), (Bosnia and Herzegovina)
and f.txt not like '%.cat.srt' -- Catalan
and f.txt not like '%.cat.srt' -- Catalan (Catalan)
and f.txt not like '%.cat.srt' -- Valencian (Spain)
and f.txt not like '%.chr.srt' -- Cherokee
and f.txt not like '%.chr.srt' -- Cherokee
and f.txt not like '%.chr.srt' -- Cherokee (Cherokee)
and f.txt not like '%.cos.srt' -- Corsican
and f.txt not like '%.cos.srt' -- Corsican (France)
and f.txt not like '%.ces.srt' -- Czech
and f.txt not like '%.ces.srt' -- Czech (Czech Republic)
and f.txt not like '%.cym.srt' -- Welsh
and f.txt not like '%.cym.srt' -- Welsh (United Kingdom)
and f.txt not like '%.dan.srt' -- Danish
and f.txt not like '%.dan.srt' -- Danish (Denmark)
and f.txt not like '%.deu.srt' -- German
and f.txt not like '%.deu.srt' -- German (Austria)
and f.txt not like '%.deu.srt' -- German (Switzerland)
and f.txt not like '%.deu.srt' -- German (Germany)
and f.txt not like '%.deu.srt' -- German (Liechtenstein)
and f.txt not like '%.deu.srt' -- German (Luxembourg)
and f.txt not like '%.dsb.srt' -- Lower Sorbian
and f.txt not like '%.dsb.srt' -- Lower Sorbian (Germany)
and f.txt not like '%.div.srt' -- Divehi
and f.txt not like '%.div.srt' -- Divehi (Maldives)
and f.txt not like '%.ell.srt' -- Greek
and f.txt not like '%.ell.srt' -- Greek (Greece)
--and f.txt not like '%.eng.srt' -- English
--and f.txt not like '%.eng.srt' -- English (Caribbean)
--and f.txt not like '%.eng.srt' -- English (Australia)
--and f.txt not like '%.eng.srt' -- English (Belize)
--and f.txt not like '%.eng.srt' -- English (Canada)
--and f.txt not like '%.eng.srt' -- English (United Kingdom)
--and f.txt not like '%.eng.srt' -- English (Hong Kong)
--and f.txt not like '%.eng.srt' -- English (Ireland)
--and f.txt not like '%.eng.srt' -- English (India)
--and f.txt not like '%.eng.srt' -- English (Jamaica)
--and f.txt not like '%.eng.srt' -- English (Malaysia)
--and f.txt not like '%.eng.srt' -- English (New Zealand)
--and f.txt not like '%.eng.srt' -- English (Philippines)
--and f.txt not like '%.eng.srt' -- English (Singapore)
--and f.txt not like '%.eng.srt' -- English (Trinidad and Tobago)
--and f.txt not like '%.eng.srt' -- English (United States)
--and f.txt not like '%.eng.srt' -- English (South Africa)
--and f.txt not like '%.eng.srt' -- English (Zimbabwe)
and f.txt not like '%.spa.srt' -- Spanish
and f.txt not like '%.est.srt' -- Estonian
and f.txt not like '%.eus.srt' -- Basque
and f.txt not like '%.fas.srt' -- Persian
and f.txt not like '%.ful.srt' -- Fulah
and f.txt not like '%.fin.srt' -- Finnish
and f.txt not like '%.fil.srt' -- Filipino
and f.txt not like '%.fao.srt' -- Faroese
and f.txt not like '%.fra.srt' -- French
and f.txt not like '%.fry.srt' -- Frisian (Netherlands)
and f.txt not like '%.gle.srt' -- Irish (Ireland)
and f.txt not like '%.gla.srt' -- Scottish Gaelic (United Kingdom)
and f.txt not like '%.glg.srt' -- Galician (Galician)
and f.txt not like '%.grn.srt' -- Guarani (Paraguay)
and f.txt not like '%.gsw.srt' -- Alsatian (France)
and f.txt not like '%.guj.srt' -- Gujarati (India)
and f.txt not like '%.hau.srt' -- Hausa (Latin), (Nigeria)
and f.txt not like '%.heb.srt' -- Hebrew (Israel)
and f.txt not like '%.hin.srt' -- Hindi (India)
and f.txt not like '%.hrv.srt' -- Croatian
and f.txt not like '%.hrb.srt' -- Croatian (Latin), (Bosnia and Herzegovina)
and f.txt not like '%.hsb.srt' -- Upper Sorbian (Germany)
and f.txt not like '%.hun.srt' -- Hungarian (Hungary)
and f.txt not like '%.hye.srt' -- Armenian (Armenia)
and f.txt not like '%.ind.srt' -- Indonesian (Indonesia)
and f.txt not like '%.ibo.srt' -- Igbo (Nigeria)
and f.txt not like '%.iii.srt' -- Yi (China)
and f.txt not like '%.isl.srt' -- Icelandic (Iceland)
and f.txt not like '%.ita.srt' -- Italian (Italy)
and f.txt not like '%.iku.srt' -- Inuktitut
and f.txt not like '%.jpn.srt' -- Japanese
and f.txt not like '%.jav.srt' -- Javanese
and f.txt not like '%.kat.srt' -- Georgian (Georgia)
and f.txt not like '%.kaz.srt' -- Kazakh (Kazakhstan)
and f.txt not like '%.kal.srt' -- Greenlandic (Greenland)
and f.txt not like '%.khm.srt' -- Khmer (Cambodia)
and f.txt not like '%.kan.srt' -- Kannada (India)
and f.txt not like '%.kor.srt' -- Korean (Korea)
and f.txt not like '%.kok.srt' -- Konkani (India)
and f.txt not like '%.kur.srt' -- Central Kurdish
and f.txt not like '%.kir.srt' -- Kyrgyz
and f.txt not like '%.ltz.srt' -- Luxembourgish
and f.txt not like '%.lao.srt' -- Lao
and f.txt not like '%.lit.srt' -- Lithuanian
and f.txt not like '%.lav.srt' -- Latvian
and f.txt not like '%.mlg.srt' -- Malagasy
and f.txt not like '%.mri.srt' -- Maori
and f.txt not like '%.mkd.srt' -- Macedonian (Former Yugoslav Republic of Macedonia)
and f.txt not like '%.mym.srt' -- Malayalam
and f.txt not like '%.mon.srt' -- Mongolian
and f.txt not like '%.moh.srt' -- Mohawk (Mohawk)
and f.txt not like '%.mar.srt' -- Marathi (India)
and f.txt not like '%.msa.srt' -- Malay (Malaysia)
and f.txt not like '%.mlt.srt' -- Maltese (Malta)
and f.txt not like '%.mya.srt' -- Burmese (Myanmar)
and f.txt not like '%.nob.srt' -- Norwegian, Bokmål (Norway)
and f.txt not like '%.nep.srt' -- Nepali (Nepal)
and f.txt not like '%.nld.srt' -- Dutch
and f.txt not like '%.nno.srt' -- Norwegian (Nynorsk)
and f.txt not like '%.nob.srt' -- Norwegian
and f.txt not like '%.nqo.srt' -- N'ko
and f.txt not like '%.nqo.srt' -- N'ko (Guinea)
and f.txt not like '%.nso.srt' -- Sesotho sa Leboa
and f.txt not like '%.nso.srt' -- Sesotho sa Leboa (South Africa)
and f.txt not like '%.oci.srt' -- Occitan
and f.txt not like '%.oci.srt' -- Occitan (France)
and f.txt not like '%.orm.srt' -- Oromo
and f.txt not like '%.orm.srt' -- Oromo (Ethiopia)
and f.txt not like '%.ori.srt' -- Odia
and f.txt not like '%.ori.srt' -- Odia (India)
and f.txt not like '%.pan.srt' -- Punjabi
and f.txt not like '%.pan.srt' -- Punjabi
and f.txt not like '%.pan.srt' -- Punjabi (Pakistan)
and f.txt not like '%.pan.srt' -- Punjabi (India)
and f.txt not like '%.pol.srt' -- Polish
and f.txt not like '%.pol.srt' -- Polish (Poland)
and f.txt not like '%.prs.srt' -- Dari
and f.txt not like '%.prs.srt' -- Dari (Afghanistan)
and f.txt not like '%.pus.srt' -- Pashto
and f.txt not like '%.pus.srt' -- Pashto (Afghanistan)
and f.txt not like '%.por.srt' -- Portuguese
and f.txt not like '%.por.srt' -- Portuguese (Angola)
and f.txt not like '%.por.srt' -- Portuguese (Brazil)
and f.txt not like '%.por.srt' -- Portuguese (Portugal)
and f.txt not like '%.qut.srt' -- K'iche'
and f.txt not like '%.qut.srt' -- K'iche' (Guatemala)
and f.txt not like '%.qub.srt' -- Quechua
and f.txt not like '%.qub.srt' -- Quechua (Bolivia)
and f.txt not like '%.que.srt' -- Quichua (Ecuador)
and f.txt not like '%.qup.srt' -- Quechua (Peru)
and f.txt not like '%.roh.srt' -- Romansh
and f.txt not like '%.roh.srt' -- Romansh (Switzerland)
and f.txt not like '%.ron.srt' -- Romanian
and f.txt not like '%.ron.srt' -- Romanian (Moldova)
and f.txt not like '%.ron.srt' -- Romanian (Romania)
and f.txt not like '%.rus.srt' -- Russian (Russia)
and f.txt not like '%.kin.srt' -- Kinyarwanda (Rwanda)
and f.txt not like '%.san.srt' -- Sanskrit (India)
and f.txt not like '%.sah.srt' -- Sakha (Russia)
and f.txt not like '%.sin.srt' -- Sindhi (Pakistan)
and f.txt not like '%.sme.srt' -- Sami (Northern)
and f.txt not like '%.slk.srt' -- Slovak (Slovakia)
and f.txt not like '%.slv.srt' -- Slovenian (Slovenia)
and f.txt not like '%.sma.srt' -- Sami, Southern (Sweden)
and f.txt not like '%.smj.srt' -- Sami, Lule (Sweden)
and f.txt not like '%.smn.srt' -- Sami, Inari (Finland)
and f.txt not like '%.sms.srt' -- Sami, Skolt (Finland)
and f.txt not like '%.sna.srt' -- Shona (Latin), (Zimbabwe)
and f.txt not like '%.som.srt' -- Somali (Somalia)
and f.txt not like '%.sqi.srt' -- Albanian (Albania)
and f.txt not like '%.srn.srt' -- Serbian (Cyrillic), (Bosnia and Herzegovina)
and f.txt not like '%.srp.srt' -- Serbian (Cyrillic), (Serbia and Montenegro (Former))
and f.txt not like '%.srp.srt' -- Serbian (Cyrillic), (Montenegro)
and f.txt not like '%.srp.srt' -- Serbian (Cyrillic), (Serbia)
and f.txt not like '%.srp.srt' -- Serbian (Latin)
and f.txt not like '%.srs.srt' -- Serbian (Latin), (Bosnia and Herzegovina)
and f.txt not like '%.srp.srt' -- Serbian (Latin), (Serbia and Montenegro (Former))
and f.txt not like '%.srp.srt' -- Serbian (Latin), (Montenegro)
and f.txt not like '%.srp.srt' -- Serbian (Latin), (Serbia)
and f.txt not like '%.sot.srt' -- Southern Sotho
and f.txt not like '%.sot.srt' -- Southern Sotho (South Africa)
and f.txt not like '%.swe.srt' -- Swedish
and f.txt not like '%.swe.srt' -- Swedish (Finland)
and f.txt not like '%.swe.srt' -- Swedish (Sweden)
and f.txt not like '%.swa.srt' -- Kiswahili
and f.txt not like '%.swa.srt' -- Kiswahili (Kenya)
and f.txt not like '%.syr.srt' -- Syriac
and f.txt not like '%.syr.srt' -- Syriac (Syria)
and f.txt not like '%.tam.srt' -- Tamil
and f.txt not like '%.tam.srt' -- Tamil (India)
and f.txt not like '%.tam.srt' -- Tamil (Sri Lanka)
and f.txt not like '%.tel.srt' -- Telugu
and f.txt not like '%.tel.srt' -- Telugu (India)
and f.txt not like '%.tgk.srt' -- Tajik
and f.txt not like '%.tgk.srt' -- Tajik (Cyrillic)
and f.txt not like '%.tgk.srt' -- Tajik (Cyrillic), (Tajikistan)
and f.txt not like '%.tha.srt' -- Thai
and f.txt not like '%.tha.srt' -- Thai (Thailand)
and f.txt not like '%.tir.srt' -- Tigrinya
and f.txt not like '%.tir.srt' -- Tigrinya (Eritrea)
and f.txt not like '%.tir.srt' -- Tigrinya (Ethiopia)
and f.txt not like '%.tuk.srt' -- Turkmen
and f.txt not like '%.tuk.srt' -- Turkmen (Turkmenistan)
and f.txt not like '%.tsn.srt' -- Setswana
and f.txt not like '%.tsn.srt' -- Setswana (Botswana)
and f.txt not like '%.tsn.srt' -- Setswana (South Africa)
and f.txt not like '%.tur.srt' -- Turkish (Turkey)
and f.txt not like '%.tso.srt' -- Tsonga (South Africa)
and f.txt not like '%.tat.srt' -- Tatar (Russia)
and f.txt not like '%.tzm.srt' -- Central Atlas Tamazight (Tifinagh), (Morocco)
and f.txt not like '%.uig.srt' -- Uyghur
and f.txt not like '%.ukr.srt' -- Ukrainian (Ukraine)
and f.txt not like '%.urd.srt' -- Urdu
and f.txt not like '%.uzb.srt' -- Uzbek
and f.txt not like '%.vie.srt' -- Vietnamese
and f.txt not like '%.wol.srt' -- Wolof
and f.txt not like '%.xho.srt' -- isiXhosa
and f.txt not like '%.yor.srt' -- Yoruba
and f.txt not like '%.zgh.srt' -- Standard Morrocan Tamazight
and f.txt not like '%.zho.srt' -- Chinese
and f.txt not like '%.zho.srt' -- Chinese (Traditional), (Taiwan)
and f.txt not like '%.zul.srt' -- isiZulu (South Africa)
and f.txt not like '%.Afrikaans.srt' -- afr
and f.txt not like '%.Afrikaans (South Africa).srt' -- afr
and f.txt not like '%.Amharic.srt' -- amh
and f.txt not like '%.Amharic (Ethiopia).srt' -- amh
and f.txt not like '%.Arabic.srt' -- ara
and f.txt not like '%.Arabic (U.A.E.).srt' -- ara
and f.txt not like '%.Arabic (Bahrain).srt' -- ara
and f.txt not like '%.Arabic (Algeria).srt' -- ara
and f.txt not like '%.Arabic (Egypt).srt' -- ara
and f.txt not like '%.Arabic (Iraq).srt' -- ara
and f.txt not like '%.Arabic (Jordan).srt' -- ara
and f.txt not like '%.Arabic (Kuwait).srt' -- ara
and f.txt not like '%.Arabic (Lebanon).srt' -- ara
and f.txt not like '%.Arabic (Libya).srt' -- ara
and f.txt not like '%.Arabic (Morocco).srt' -- ara
and f.txt not like '%.Arabic (Oman).srt' -- ara
and f.txt not like '%.Arabic (Qatar).srt' -- ara
and f.txt not like '%.Arabic (Saudi Arabia).srt' -- ara
and f.txt not like '%.Arabic (Syria).srt' -- ara
and f.txt not like '%.Arabic (Tunisia).srt' -- ara
and f.txt not like '%.Arabic (Yemen).srt' -- ara
and f.txt not like '%.Mapudungun.srt' -- arn
and f.txt not like '%.Mapudungun (Chile).srt' -- arn
and f.txt not like '%.Assamese.srt' -- asm
and f.txt not like '%.Assamese (India).srt' -- asm
and f.txt not like '%.Azerbaijani.srt' -- aze
and f.txt not like '%.Azerbaijani (Cyrillic).srt' -- aze
and f.txt not like '%.Azerbaijani (Cyrillic), (Azerbaijan).srt' -- aze
and f.txt not like '%.Azerbaijani (Latin).srt' -- aze
and f.txt not like '%.Azerbaijani (Latin), (Azerbaijan).srt' -- aze
and f.txt not like '%.Bashkir.srt' -- bak
and f.txt not like '%.Bashkir (Russia).srt' -- bak
and f.txt not like '%.Belarusian.srt' -- bel
and f.txt not like '%.Belarusian (Belarus).srt' -- bel
and f.txt not like '%.Bulgarian.srt' -- bul
and f.txt not like '%.Bulgarian (Bulgaria).srt' -- bul
and f.txt not like '%.Bangla.srt' -- bng
and f.txt not like '%.Bangla (Bangladesh).srt' -- bng
and f.txt not like '%.Bangla (India).srt' -- bng
and f.txt not like '%.Tibetan.srt' -- bod
and f.txt not like '%.Tibetan (China).srt' -- bod
and f.txt not like '%.Breton.srt' -- bre
and f.txt not like '%.Breton (France).srt' -- bre
and f.txt not like '%.Bosnian.srt' -- bsb
and f.txt not like '%.Bosnian (Cyrillic).srt' -- bsc
and f.txt not like '%.Bosnian (Cyrillic), (Bosnia and Herzegovina).srt' -- bsc
and f.txt not like '%.Bosnian (Latin).srt' -- bsb
and f.txt not like '%.Bosnian (Latin), (Bosnia and Herzegovina).srt' -- bsb
and f.txt not like '%.Catalan.srt' -- cat
and f.txt not like '%.Catalan (Catalan).srt' -- cat
and f.txt not like '%.Valencian (Spain).srt' -- cat
and f.txt not like '%.Cherokee.srt' -- chr
and f.txt not like '%.Cherokee.srt' -- chr
and f.txt not like '%.Cherokee (Cherokee).srt' -- chr
and f.txt not like '%.Corsican.srt' -- cos
and f.txt not like '%.Corsican (France).srt' -- cos
and f.txt not like '%.Czech.srt' -- ces
and f.txt not like '%.Czech (Czech Republic).srt' -- ces
and f.txt not like '%.Welsh.srt' -- cym
and f.txt not like '%.Welsh (United Kingdom).srt' -- cym
and f.txt not like '%.Danish.srt' -- dan
and f.txt not like '%.Danish (Denmark).srt' -- dan
and f.txt not like '%.German.srt' -- deu
and f.txt not like '%.German (Austria).srt' -- deu
and f.txt not like '%.German (Switzerland).srt' -- deu
and f.txt not like '%.German (Germany).srt' -- deu
and f.txt not like '%.German (Liechtenstein).srt' -- deu
and f.txt not like '%.German (Luxembourg).srt' -- deu
and f.txt not like '%.Lower Sorbian.srt' -- dsb
and f.txt not like '%.Lower Sorbian (Germany).srt' -- dsb
and f.txt not like '%.Divehi.srt' -- div
and f.txt not like '%.Divehi (Maldives).srt' -- div
and f.txt not like '%.Greek.srt' -- ell
and f.txt not like '%.Greek (Greece).srt' -- ell
--and f.txt not like '%.English.srt' -- eng
--and f.txt not like '%.English (Caribbean).srt' -- eng
--and f.txt not like '%.English (Australia).srt' -- eng
--and f.txt not like '%.English (Belize).srt' -- eng
--and f.txt not like '%.English (Canada).srt' -- eng
--and f.txt not like '%.English (United Kingdom).srt' -- eng
--and f.txt not like '%.English (Hong Kong).srt' -- eng
--and f.txt not like '%.English (Ireland).srt' -- eng
--and f.txt not like '%.English (India).srt' -- eng
--and f.txt not like '%.English (Jamaica).srt' -- eng
--and f.txt not like '%.English (Malaysia).srt' -- eng
--and f.txt not like '%.English (New Zealand).srt' -- eng
--and f.txt not like '%.English (Philippines).srt' -- eng
--and f.txt not like '%.English (Singapore).srt' -- eng
--and f.txt not like '%.English (Trinidad and Tobago).srt' -- eng
--and f.txt not like '%.English (United States).srt' -- eng
--and f.txt not like '%.English (South Africa).srt' -- eng
--and f.txt not like '%.English (Zimbabwe).srt' -- eng
and f.txt not like '%.Spanish.srt' -- spa
and f.txt not like '%.Spanish (Latin America).srt' -- spa
and f.txt not like '%.Spanish (Argentina).srt' -- spa
and f.txt not like '%.Spanish (Bolivia).srt' -- spa
and f.txt not like '%.Spanish (Chile).srt' -- spa
and f.txt not like '%.Spanish (Colombia).srt' -- spa
and f.txt not like '%.Spanish (Costa Rica).srt' -- spa
and f.txt not like '%.Spanish (Dominican Republic).srt' -- spa
and f.txt not like '%.Spanish (Ecuador).srt' -- spa
and f.txt not like '%.Spanish (Spain), (International Sort).srt' -- spa
and f.txt not like '%.Spanish (Guatemala).srt' -- spa
and f.txt not like '%.Spanish (Honduras).srt' -- spa
and f.txt not like '%.Spanish (Mexico).srt' -- spa
and f.txt not like '%.Spanish (Nicaragua).srt' -- spa
and f.txt not like '%.Spanish (Panama).srt' -- spa
and f.txt not like '%.Spanish (Peru).srt' -- spa
and f.txt not like '%.Spanish (Puerto Rico).srt' -- spa
and f.txt not like '%.Spanish (Paraguay).srt' -- spa
and f.txt not like '%.Spanish (El Salvador).srt' -- spa
and f.txt not like '%.Spanish (United States).srt' -- spa
and f.txt not like '%.Spanish (Uruguay).srt' -- spa
and f.txt not like '%.Spanish (Bolivarian Republic of Venezuela).srt' -- spa
and f.txt not like '%.Estonian.srt' -- est
and f.txt not like '%.Estonian (Estonia).srt' -- est
and f.txt not like '%.Basque.srt' -- eus
and f.txt not like '%.Basque (Basque).srt' -- eus
and f.txt not like '%.Persian.srt' -- fas
and f.txt not like '%.Persian.srt' -- fas
and f.txt not like '%.Fulah.srt' -- ful
and f.txt not like '%.Fulah.srt' -- ful
and f.txt not like '%.Fulah (Latin), (Senegal).srt' -- ful
and f.txt not like '%.Finnish.srt' -- fin
and f.txt not like '%.Finnish (Finland).srt' -- fin
and f.txt not like '%.Filipino.srt' -- fil
and f.txt not like '%.Filipino (Philippines).srt' -- fil
and f.txt not like '%.Faroese.srt' -- fao
and f.txt not like '%.Faroese (Faroe Islands).srt' -- fao
and f.txt not like '%.French.srt' -- fra
and f.txt not like '%.French (Belgium).srt' -- fra
and f.txt not like '%.French (Canada).srt' -- fra
and f.txt not like '%.French (Congo [DRC]).srt' -- fra
and f.txt not like '%.French (Switzerland).srt' -- fra
and f.txt not like '%.French (Ivory Coast).srt' -- fra
and f.txt not like '%.French (Cameroon).srt' -- fra
and f.txt not like '%.French (France).srt' -- fra
and f.txt not like '%.French (Haiti).srt' -- fra
and f.txt not like '%.French (Luxembourg).srt' -- fra
and f.txt not like '%.French (Morocco).srt' -- fra
and f.txt not like '%.French (Monaco).srt' -- fra
and f.txt not like '%.French (Mali).srt' -- fra
and f.txt not like '%.French (Réunion).srt' -- fra
and f.txt not like '%.French (Senegal).srt' -- fra
and f.txt not like '%.Frisian.srt' -- fry
and f.txt not like '%.Frisian (Netherlands).srt' -- fry
and f.txt not like '%.Irish.srt' -- gle
and f.txt not like '%.Irish (Ireland).srt' -- gle
and f.txt not like '%.Scottish Gaelic.srt' -- gla
and f.txt not like '%.Scottish Gaelic (United Kingdom).srt' -- gla
and f.txt not like '%.Galician.srt' -- glg
and f.txt not like '%.Galician (Galician).srt' -- glg
and f.txt not like '%.Guarani.srt' -- grn
and f.txt not like '%.Guarani (Paraguay).srt' -- grn
and f.txt not like '%.Alsatian.srt' -- gsw
and f.txt not like '%.Alsatian (France).srt' -- gsw
and f.txt not like '%.Gujarati.srt' -- guj
and f.txt not like '%.Gujarati (India).srt' -- guj
and f.txt not like '%.Hausa.srt' -- hau
and f.txt not like '%.Hausa (Latin).srt' -- hau
and f.txt not like '%.Hausa (Latin), (Nigeria).srt' -- hau
and f.txt not like '%.Hawaiian.srt' -- haw
and f.txt not like '%.Hawaiian (United States).srt' -- haw
and f.txt not like '%.Hebrew.srt' -- heb
and f.txt not like '%.Hebrew (Israel).srt' -- heb
and f.txt not like '%.Hindi.srt' -- hin
and f.txt not like '%.Hindi (India).srt' -- hin
and f.txt not like '%.Croatian.srt' -- hrv
and f.txt not like '%.Croatian (Latin), (Bosnia and Herzegovina).srt' -- hrb
and f.txt not like '%.Croatian (Croatia).srt' -- hrv
and f.txt not like '%.Upper Sorbian.srt' -- hsb
and f.txt not like '%.Upper Sorbian (Germany).srt' -- hsb
and f.txt not like '%.Hungarian.srt' -- hun
and f.txt not like '%.Hungarian (Hungary).srt' -- hun
and f.txt not like '%.Armenian.srt' -- hye
and f.txt not like '%.Armenian (Armenia).srt' -- hye
and f.txt not like '%.Indonesian.srt' -- ind
and f.txt not like '%.Indonesian (Indonesia).srt' -- ind
and f.txt not like '%.Igbo.srt' -- ibo
and f.txt not like '%.Igbo (Nigeria).srt' -- ibo
and f.txt not like '%.Yi.srt' -- iii
and f.txt not like '%.Yi (China).srt' -- iii
and f.txt not like '%.Icelandic.srt' -- isl
and f.txt not like '%.Icelandic (Iceland).srt' -- isl
and f.txt not like '%.Italian.srt' -- ita
and f.txt not like '%.Italian (Switzerland).srt' -- ita
and f.txt not like '%.Italian (Italy).srt' -- ita
and f.txt not like '%.Inuktitut.srt' -- iku
and f.txt not like '%.Inuktitut (Syllabics).srt' -- iku
and f.txt not like '%.Inuktitut (Syllabics), (Canada).srt' -- iku
and f.txt not like '%.Inuktitut (Latin).srt' -- iku
and f.txt not like '%.Inuktitut (Latin), (Canada).srt' -- iku
and f.txt not like '%.Japanese.srt' -- jpn
and f.txt not like '%.Japanese (Japan).srt' -- jpn
and f.txt not like '%.Javanese.srt' -- jav
and f.txt not like '%.Javanese.srt' -- jav
and f.txt not like '%.Javanese (Indonesia).srt' -- jav
and f.txt not like '%.Georgian.srt' -- kat
and f.txt not like '%.Georgian (Georgia).srt' -- kat
and f.txt not like '%.Kazakh.srt' -- kaz
and f.txt not like '%.Kazakh (Kazakhstan).srt' -- kaz
and f.txt not like '%.Greenlandic.srt' -- kal
and f.txt not like '%.Greenlandic (Greenland).srt' -- kal
and f.txt not like '%.Khmer.srt' -- khm
and f.txt not like '%.Khmer (Cambodia).srt' -- khm
and f.txt not like '%.Kannada.srt' -- kan
and f.txt not like '%.Kannada (India).srt' -- kan
and f.txt not like '%.Korean.srt' -- kor
and f.txt not like '%.Korean (Korea).srt' -- kor
and f.txt not like '%.Konkani.srt' -- kok
and f.txt not like '%.Konkani (India).srt' -- kok
and f.txt not like '%.Central Kurdish.srt' -- kur
and f.txt not like '%.Central Kurdish.srt' -- kur
and f.txt not like '%.Central Kurdish (Iraq).srt' -- kur
and f.txt not like '%.Kyrgyz.srt' -- kir
and f.txt not like '%.Kyrgyz (Kyrgyzstan).srt' -- kir
and f.txt not like '%.Luxembourgish.srt' -- ltz
and f.txt not like '%.Luxembourgish (Luxembourg).srt' -- ltz
and f.txt not like '%.Lao.srt' -- lao
and f.txt not like '%.Lao (Lao PDR).srt' -- lao
and f.txt not like '%.Lithuanian.srt' -- lit
and f.txt not like '%.Lithuanian (Lithuania).srt' -- lit
and f.txt not like '%.Latvian.srt' -- lav
and f.txt not like '%.Latvian (Latvia).srt' -- lav
and f.txt not like '%.Malagasy.srt' -- mlg
and f.txt not like '%.Malagasy (Madagascar).srt' -- mlg
and f.txt not like '%.Maori.srt' -- mri
and f.txt not like '%.Maori (New Zealand).srt' -- mri
and f.txt not like '%.Macedonian (Former Yugoslav Republic of Macedonia).srt' -- mkd
and f.txt not like '%.Macedonian (Former Yugoslav Republic of Macedonia).srt' -- mkd
and f.txt not like '%.Malayalam.srt' -- mym
and f.txt not like '%.Malayalam (India).srt' -- mym
and f.txt not like '%.Mongolian.srt' -- mon
and f.txt not like '%.Mongolian (Cyrillic).srt' -- mon
and f.txt not like '%.Mongolian (Cyrillic), (Mongolia).srt' -- mon
and f.txt not like '%.Mongolian (Traditional Mongolian).srt' -- mon
and f.txt not like '%.Mongolian (Traditional Mongolian), (China).srt' -- mon
and f.txt not like '%.Mongolian (Traditional Mongolian), (Mongolia).srt' -- mon
and f.txt not like '%.Mohawk.srt' -- moh
and f.txt not like '%.Mohawk (Mohawk).srt' -- moh
and f.txt not like '%.Marathi.srt' -- mar
and f.txt not like '%.Marathi (India).srt' -- mar
and f.txt not like '%.Malay.srt' -- msa
and f.txt not like '%.Malay (Brunei Darussalam).srt' -- msa
and f.txt not like '%.Malay (Malaysia).srt' -- msa
and f.txt not like '%.Maltese.srt' -- mlt
and f.txt not like '%.Maltese (Malta).srt' -- mlt
and f.txt not like '%.Burmese.srt' -- mya
and f.txt not like '%.Burmese (Myanmar).srt' -- mya
and f.txt not like '%.Norwegian (Bokmål).srt' -- nob
and f.txt not like '%.Norwegian, Bokmål (Norway).srt' -- nob
and f.txt not like '%.Nepali.srt' -- nep
and f.txt not like '%.Nepali (India).srt' -- nep
and f.txt not like '%.Nepali (Nepal).srt' -- nep
and f.txt not like '%.Dutch.srt' -- nld
and f.txt not like '%.Dutch (Belgium).srt' -- nld
and f.txt not like '%.Dutch (Netherlands).srt' -- nld
and f.txt not like '%.Norwegian (Nynorsk).srt' -- nno
and f.txt not like '%.Norwegian, Nynorsk (Norway).srt' -- nno
and f.txt not like '%.Norwegian.srt' -- nob
and f.txt not like '%.N''ko.srt' -- nqo
and f.txt not like '%.N''ko (Guinea).srt' -- nqo
and f.txt not like '%.Sesotho sa Leboa.srt' -- nso
and f.txt not like '%.Sesotho sa Leboa (South Africa).srt' -- nso
and f.txt not like '%.Occitan.srt' -- oci
and f.txt not like '%.Occitan (France).srt' -- oci
and f.txt not like '%.Oromo.srt' -- orm
and f.txt not like '%.Oromo (Ethiopia).srt' -- orm
and f.txt not like '%.Odia.srt' -- ori
and f.txt not like '%.Odia (India).srt' -- ori
and f.txt not like '%.Punjabi.srt' -- pan
and f.txt not like '%.Punjabi.srt' -- pan
and f.txt not like '%.Punjabi (Pakistan).srt' -- pan
and f.txt not like '%.Punjabi (India).srt' -- pan
and f.txt not like '%.Polish.srt' -- pol
and f.txt not like '%.Polish (Poland).srt' -- pol
and f.txt not like '%.Dari.srt' -- prs
and f.txt not like '%.Dari (Afghanistan).srt' -- prs
and f.txt not like '%.Pashto.srt' -- pus
and f.txt not like '%.Pashto (Afghanistan).srt' -- pus
and f.txt not like '%.Portuguese.srt' -- por
and f.txt not like '%.Portuguese (Angola).srt' -- por
and f.txt not like '%.Portuguese (Brazil).srt' -- por
and f.txt not like '%.Portuguese (Portugal).srt' -- por
and f.txt not like '%.K''iche''.srt' -- qut
and f.txt not like '%.K''iche'' (Guatemala).srt' -- qut
and f.txt not like '%.Quechua.srt' -- qub
and f.txt not like '%.Quechua (Bolivia).srt' -- qub
and f.txt not like '%.Quichua (Ecuador).srt' -- que
and f.txt not like '%.Quechua (Peru).srt' -- qup
and f.txt not like '%.Romansh.srt' -- roh
and f.txt not like '%.Romansh (Switzerland).srt' -- roh
and f.txt not like '%.Romanian.srt' -- ron
and f.txt not like '%.Romanian (Moldova).srt' -- ron
and f.txt not like '%.Romanian (Romania).srt' -- ron
and f.txt not like '%.Russian.srt' -- rus
and f.txt not like '%.Russian (Russia).srt' -- rus
and f.txt not like '%.Kinyarwanda.srt' -- kin
and f.txt not like '%.Kinyarwanda (Rwanda).srt' -- kin
and f.txt not like '%.Sanskrit.srt' -- san
and f.txt not like '%.Sanskrit (India).srt' -- san
and f.txt not like '%.Sakha.srt' -- sah
and f.txt not like '%.Sakha (Russia).srt' -- sah
and f.txt not like '%.Sindhi.srt' -- sin
and f.txt not like '%.Sindhi.srt' -- sin
and f.txt not like '%.Sindhi (Pakistan).srt' -- sin
and f.txt not like '%.Sami (Northern).srt' -- sme
and f.txt not like '%.Sami, Northern (Finland).srt' -- sme
and f.txt not like '%.Sami, Northern (Norway).srt' -- sme
and f.txt not like '%.Sami, Northern (Sweden).srt' -- sme
and f.txt not like '%.Sinhala.srt' -- sin
and f.txt not like '%.Sinhala (Sri Lanka).srt' -- sin
and f.txt not like '%.Slovak.srt' -- slk
and f.txt not like '%.Slovak (Slovakia).srt' -- slk
and f.txt not like '%.Slovenian.srt' -- slv
and f.txt not like '%.Slovenian (Slovenia).srt' -- slv
and f.txt not like '%.Sami (Southern).srt' -- sma
and f.txt not like '%.Sami, Southern (Norway).srt' -- sma
and f.txt not like '%.Sami, Southern (Sweden).srt' -- sma
and f.txt not like '%.Sami (Lule).srt' -- smj
and f.txt not like '%.Sami, Lule (Norway).srt' -- smj
and f.txt not like '%.Sami, Lule (Sweden).srt' -- smj
and f.txt not like '%.Sami (Inari).srt' -- smn
and f.txt not like '%.Sami, Inari (Finland).srt' -- smn
and f.txt not like '%.Sami (Skolt).srt' -- sms
and f.txt not like '%.Sami, Skolt (Finland).srt' -- sms
and f.txt not like '%.Shona.srt' -- sna
and f.txt not like '%.Shona (Latin).srt' -- sna
and f.txt not like '%.Shona (Latin), (Zimbabwe).srt' -- sna
and f.txt not like '%.Somali.srt' -- som
and f.txt not like '%.Somali (Somalia).srt' -- som
and f.txt not like '%.Albanian.srt' -- sqi
and f.txt not like '%.Albanian (Albania).srt' -- sqi
and f.txt not like '%.Serbian.srt' -- srp
and f.txt not like '%.Serbian (Cyrillic).srt' -- srp
and f.txt not like '%.Serbian (Cyrillic), (Bosnia and Herzegovina).srt' -- srn
and f.txt not like '%.Serbian (Cyrillic), (Serbia and Montenegro (Former)).srt' -- srp
and f.txt not like '%.Serbian (Cyrillic), (Montenegro).srt' -- srp
and f.txt not like '%.Serbian (Cyrillic), (Serbia).srt' -- srp
and f.txt not like '%.Serbian (Latin).srt' -- srp
and f.txt not like '%.Serbian (Latin), (Bosnia and Herzegovina).srt' -- srs
and f.txt not like '%.Serbian (Latin), (Serbia and Montenegro (Former)).srt' -- srp
and f.txt not like '%.Serbian (Latin), (Montenegro).srt' -- srp
and f.txt not like '%.Serbian (Latin), (Serbia).srt' -- srp
and f.txt not like '%.Southern Sotho.srt' -- sot
and f.txt not like '%.Southern Sotho (South Africa).srt' -- sot
and f.txt not like '%.Swedish.srt' -- swe
and f.txt not like '%.Swedish (Finland).srt' -- swe
and f.txt not like '%.Swedish (Sweden).srt' -- swe
and f.txt not like '%.Kiswahili.srt' -- swa
and f.txt not like '%.Kiswahili (Kenya).srt' -- swa
and f.txt not like '%.Syriac.srt' -- syr
and f.txt not like '%.Syriac (Syria).srt' -- syr
and f.txt not like '%.Tamil.srt' -- tam
and f.txt not like '%.Tamil (India).srt' -- tam
and f.txt not like '%.Tamil (Sri Lanka).srt' -- tam
and f.txt not like '%.Telugu.srt' -- tel
and f.txt not like '%.Telugu (India).srt' -- tel
and f.txt not like '%.Tajik.srt' -- tgk
and f.txt not like '%.Tajik (Cyrillic).srt' -- tgk
and f.txt not like '%.Tajik (Cyrillic), (Tajikistan).srt' -- tgk
and f.txt not like '%.Thai.srt' -- tha
and f.txt not like '%.Thai (Thailand).srt' -- tha
and f.txt not like '%.Tigrinya.srt' -- tir
and f.txt not like '%.Tigrinya (Eritrea).srt' -- tir
and f.txt not like '%.Tigrinya (Ethiopia).srt' -- tir
and f.txt not like '%.Turkmen.srt' -- tuk
and f.txt not like '%.Turkmen (Turkmenistan).srt' -- tuk
and f.txt not like '%.Setswana.srt' -- tsn
and f.txt not like '%.Setswana (Botswana).srt' -- tsn
and f.txt not like '%.Setswana (South Africa).srt' -- tsn
and f.txt not like '%.Turkish.srt' -- tur
and f.txt not like '%.Turkish (Turkey).srt' -- tur
and f.txt not like '%.Tsonga.srt' -- tso
and f.txt not like '%.Tsonga (South Africa).srt' -- tso
and f.txt not like '%.Tatar.srt' -- tat
and f.txt not like '%.Tatar (Russia).srt' -- tat
and f.txt not like '%.Tamazight.srt' -- tzm
and f.txt not like '%.Central Atlas Tamazight (Latin).srt' -- tzm
and f.txt not like '%.Central Atlas Tamazight (Latin), (Algeria).srt' -- tzm
and f.txt not like '%.Central Atlas Tamazight (Tifinagh).srt' -- tzm
and f.txt not like '%.Central Atlas Tamazight (Tifinagh), (Morocco).srt' -- tzm
and f.txt not like '%.Uyghur.srt' -- uig
and f.txt not like '%.Uyghur (China).srt' -- uig
and f.txt not like '%.Ukrainian.srt' -- ukr
and f.txt not like '%.Ukrainian (Ukraine).srt' -- ukr
and f.txt not like '%.Urdu.srt' -- urd
and f.txt not like '%.Urdu (India).srt' -- urd
and f.txt not like '%.Urdu (Pakistan).srt' -- urd
and f.txt not like '%.Uzbek.srt' -- uzb
and f.txt not like '%.Uzbek (Cyrillic).srt' -- uzb
and f.txt not like '%.Uzbek (Cyrillic), (Uzbekistan).srt' -- uzb
and f.txt not like '%.Uzbek (Latin).srt' -- uzb
and f.txt not like '%.Uzbek (Latin), (Uzbekistan).srt' -- uzb
and f.txt not like '%.Vietnamese.srt' -- vie
and f.txt not like '%.Vietnamese (Vietnam).srt' -- vie
and f.txt not like '%.Wolof.srt' -- wol
and f.txt not like '%.Wolof (Senegal).srt' -- wol
and f.txt not like '%.isiXhosa.srt' -- xho
and f.txt not like '%.isiXhosa (South Africa).srt' -- xho
and f.txt not like '%.Yoruba.srt' -- yor
and f.txt not like '%.Yoruba (Nigeria).srt' -- yor
and f.txt not like '%.Standard Morrocan Tamazight.srt' -- zgh
and f.txt not like '%.Standard Morrocan Tamazight (Tifinagh).srt' -- zgh
and f.txt not like '%.Standard Morrocan Tamazight (Tifinagh), (Morocco).srt' -- zgh
and f.txt not like '%.Chinese.srt' -- zho
and f.txt not like '%.Chinese (Simplified) Legacy.srt' -- zho
and f.txt not like '%.Chinese (Traditional) Legacy.srt' -- zho
and f.txt not like '%.Chinese (Simplified), (China).srt' -- zho
and f.txt not like '%.Chinese (Traditional), (Hong Kong SAR).srt' -- zho
and f.txt not like '%.Chinese (Simplified).srt' -- zho
and f.txt not like '%.Chinese (Traditional).srt' -- zho
and f.txt not like '%.Chinese (Traditional), (Macao SAR).srt' -- zho
and f.txt not like '%.Chinese (Simplified), (Singapore).srt' -- zho
and f.txt not like '%.Chinese (Traditional), (Taiwan).srt' -- zho
and f.txt not like '%.isiZulu.srt' -- zul
and f.txt not like '%.isiZulu (South Africa).srt' -- zul
-- ?
and f.txt not like '%latin.srt'
and f.txt not like '%sample%'
and f.txt not like '%Sample.%'
and f.final_extension not in('sub', 'idx')
and f.final_extension in('srt')
and f.txt not like '%SUBENG.srt'
and f.txt not like '%ENG.srt'
and f.txt not like '%.en.srt'
and f.txt not like '%_eng.srt'
and f.txt not like '%_eng.HI.srt'
and f.txt not like '%_Eng_HI.srt'
and f.txt not like '%_Eng.srt'
and f.txt not like '%.EN.srt'
and f.txt not like '%English.srt'
and f.txt not like '%/English(SDH).srt'
and f.txt not like '%english.srt'
and f.txt not like '%- English Subtitle/%.srt'
