DROP TABLE P
DROP TABLE S0
DROP TABLE S1
DROP TABLE S2
DROP TABLE S3
CREATE TABLE P(Indice int, Value BIGINT)
CREATE TABLE S0(Indice int, Value BIGINT)
CREATE TABLE S1(Indice int, Value BIGINT)
CREATE TABLE S2(Indice int, Value BIGINT)
CREATE TABLE S3(Indice int, Value BIGINT)
GO
DROP FUNCTION WORDBYTE0
DROP FUNCTION WORDBYTE1
DROP FUNCTION WORDBYTE2
DROP FUNCTION WORDBYTE3
DROP FUNCTION FNC_CHAVE
DROP FUNCTION FNC_XOR
DROP FUNCTION FNC_ROUND
DROP FUNCTION FNC_ENCIPHER
DROP FUNCTION FNC_DECIPHER
DROP FUNCTION FNC_WORDESCAPE
DROP PROCEDURE PRC_INSERTVALUES
GO

CREATE FUNCTION WORDBYTE0(@VALUE BIGINT)
	RETURNS BIGINT
AS 
BEGIN
	RETURN FLOOR(FLOOR(FLOOR(@VALUE / 256)/256)/256) % 256
END
GO

CREATE FUNCTION WORDBYTE1(@VALUE BIGINT)
	RETURNS BIGINT
AS 
BEGIN
	RETURN FLOOR(FLOOR(@VALUE / 256)/256) % 256
END
GO

CREATE FUNCTION WORDBYTE2(@VALUE BIGINT)
	RETURNS BIGINT
AS 
BEGIN
	RETURN FLOOR(@VALUE / 256) % 256
END
GO

CREATE FUNCTION WORDBYTE3(@VALUE BIGINT)
	RETURNS BIGINT
AS 
BEGIN
	RETURN @VALUE % 256
END
GO

CREATE FUNCTION FNC_CHAVE(@Key varchar(max))
	RETURNS varchar(max)
AS 
BEGIN

	IF LEN(@Key) > 56
		SET @Key = SUBSTRING(@Key,1,56)
		
	RETURN @Key

END
GO

CREATE FUNCTION FNC_XOR(@V BIGINT,@V2 BIGINT)
	RETURNS BIGINT
AS 
BEGIN
	
	DECLARE @R BIGINT = @V ^ @V2;

	IF @R < 0
		SET @R = 4294967295 + 1 + @R;

	RETURN @R;

END
GO

CREATE FUNCTION FNC_ROUND(@A BIGINT,@B BIGINT, @N INT)
	RETURNS BIGINT
AS 
BEGIN
	DECLARE @R1 BIGINT,
			@R2 BIGINT,
			@R3 BIGINT;

	/*
	(SELECT [dbo].[FNC_XOR](7002872272,648242737))
		((SELECT Value FROM S0 WHERE Indice = (SELECT [dbo].[WORDBYTE0](120074867))) +
		 (SELECT Value FROM S1 WHERE Indice = (SELECT [dbo].[WORDBYTE1](120074867)))),
		 (SELECT Value FROM S2 WHERE Indice = (SELECT [dbo].[WORDBYTE2](120074867)))
	));
	SELECT 4046225305 + 2956646967, 648242737 / 7002872272

	SELECT CAST(7002872272 AS BIGINT) ^ CAST(648242737 AS SMALLINT)
	*/
	SET @R1 = (SELECT [dbo].[FNC_XOR](
		((SELECT Value FROM S0 WHERE Indice = (SELECT [dbo].[WORDBYTE0](@B))) +
		 (SELECT Value FROM S1 WHERE Indice = (SELECT [dbo].[WORDBYTE1](@B)))),
		 (SELECT Value FROM S2 WHERE Indice = (SELECT [dbo].[WORDBYTE2](@B)))
	));

	SET @R2 = (SELECT [dbo].[FNC_XOR](
		(@R1 + (SELECT Value FROM S3 WHERE Indice = (SELECT [dbo].[WORDBYTE3](@B)))),
		(SELECT Value FROM P WHERE Indice = @N)
	));

	SET @R3 = (SELECT [dbo].[FNC_XOR](@A,@R2))


	RETURN @R3;

END
GO

CREATE FUNCTION FNC_ENCIPHER(@XLPAR BIGINT,@XRPAR BIGINT)
	RETURNS @r table (v1 BIGINT, v2 BIGINT)
AS
BEGIN
	DECLARE @Xl BIGINT,
			@Xr BIGINT;

	SET @Xl = @XLPAR;
	SET @Xr = @XRPAR;
	
	/*
	(SELECT [dbo].[FNC_XOR](0, 1465781993))
	(SELECT [dbo].[FNC_ROUND](0, 1465781993, 1))
	(SELECT [dbo].[FNC_ROUND](1465781993, 120074867, 2))
	*/
	SET @Xl = (SELECT [dbo].[FNC_XOR](@Xl, (SELECT Value FROM P WHERE Indice = 0)))
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 1)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 2));
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 3)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 4));
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 5)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 6));
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 7)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 8));
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 9)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 10));
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 11)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 12));
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 13)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 14));
	SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 15)); SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 16));
	SET @Xr = (SELECT [dbo].[FNC_XOR](@Xr, (SELECT Value FROM P WHERE Indice = 17)));

	INSERT INTO @r VALUES(@Xl, @Xr)
		
	RETURN

END
GO

CREATE FUNCTION FNC_DECIPHER(@XLPAR BIGINT,@XRPAR BIGINT)
	RETURNS @r table (v1 BIGINT, v2 BIGINT)
AS
BEGIN
	DECLARE @Xl BIGINT,
			@Xr BIGINT;

	SELECT @Xl = @XLPAR;
	SELECT @Xr = @XRPAR;

	SET @Xl = (SELECT [dbo].[FNC_XOR](@Xl, (SELECT Value FROM P WHERE Indice = 17)))
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 15)); SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 16));
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 13)); SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 14));
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 11)); SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 12));
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 9));  SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 10));
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 7));  SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 8));
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 5));  SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 6));
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 3));  SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 4));
	SET @Xl = (SELECT [dbo].[FNC_ROUND](@Xr, @Xl, 1));  SET @Xr = (SELECT [dbo].[FNC_ROUND](@Xl, @Xr, 2));
	SET @Xr = (SELECT [dbo].[FNC_XOR](@Xr, (SELECT Value FROM P WHERE Indice = 0)));

	INSERT INTO @r
	SELECT @Xl, @Xr
		
	RETURN

END
GO

CREATE FUNCTION FNC_WORDESCAPE(@W BIGINT)
	RETURNS VARCHAR(MAX)
AS 
BEGIN
	
	DECLARE @R		VARCHAR(MAX),
			@COUNT	INT = 3,
			@T		INT,
			@T1		INT;
	DECLARE @TB TABLE(Indice int, Value int);

	INSERT INTO @TB 
	VALUES	(0,(SELECT [dbo].[WORDBYTE3](@W))),
			(1,(SELECT [dbo].[WORDBYTE2](@W))),
			(2,(SELECT [dbo].[WORDBYTE1](@W))),
			(3,(SELECT [dbo].[WORDBYTE0](@W)));

	WHILE @COUNT >= 0
		BEGIN
			SET @T = FLOOR((SELECT Value FROM @TB WHERE Indice = @COUNT) / 16);
			SET @T1 = (SELECT Value FROM @TB WHERE Indice = @COUNT) / 16;
			IF @T < 10
				SET @T += 48;
			ELSE
				SET @T += 55;
			IF @T1 < 10
				SET @T1 += 48;
			ELSE
				SET @T1 += 55;
			SET @R += CHAR(@T) + CHAR(@T1);
			SET @COUNT -= 1;
		END

	RETURN @R

END
GO

CREATE PROCEDURE PRC_INSERTVALUES
AS
BEGIN

	DELETE FROM P;
	DELETE FROM S0;
	DELETE FROM S1;
	DELETE FROM S2;
	DELETE FROM S3;

	INSERT INTO P
		VALUES	(0,608135816),
				(1,2242054355),
				(2,320440878),
				(3,57701188),
				(4,2752067618),
				(5,698298832),
				(6,137296536),
				(7,3964562569),
				(8,1160258022),
				(9,953160567),
				(10,3193202383),
				(11,887688300),
				(12,3232508343),
				(13,3380367581),
				(14,1065670069),
				(15,3041331479),
				(16,2450970073),
				(17,2306472731);

	INSERT INTO S0
		VALUES	(0,3509652390),
				(1,2564797868),
				(2,805139163),
				(3,3491422135),
				(4,3101798381),
				(5,1780907670),
				(6,3128725573),
				(7,4046225305),
				(8,614570311),
				(9,3012652279),
				(10,134345442),
				(11,2240740374),
				(12,1667834072),
				(13,1901547113),
				(14,2757295779),
				(15,4103290238),
				(16,227898511),
				(17,1921955416),
				(18,1904987480),
				(19,2182433518),
				(20,2069144605),
				(21,3260701109),
				(22,2620446009),
				(23,720527379),
				(24,3318853667),
				(25,677414384),
				(26,3393288472),
				(27,3101374703),
				(28,2390351024),
				(29,1614419982),
				(30,1822297739),
				(31,2954791486),
				(32,3608508353),
				(33,3174124327),
				(34,2024746970),
				(35,1432378464),
				(36,3864339955),
				(37,2857741204),
				(38,1464375394),
				(39,1676153920),
				(40,1439316330),
				(41,715854006),
				(42,3033291828),
				(43,289532110),
				(44,2706671279),
				(45,2087905683),
				(46,3018724369),
				(47,1668267050),
				(48,732546397),
				(49,1947742710),
				(50,3462151702),
				(51,2609353502),
				(52,2950085171),
				(53,1814351708),
				(54,2050118529),
				(55,680887927),
				(56,999245976),
				(57,1800124847),
				(58,3300911131),
				(59,1713906067),
				(60,1641548236),
				(61,4213287313),
				(62,1216130144),
				(63,1575780402),
				(64,4018429277),
				(65,3917837745),
				(66,3693486850),
				(67,3949271944),
				(68,596196993),
				(69,3549867205),
				(70,258830323),
				(71,2213823033),
				(72,772490370),
				(73,2760122372),
				(74,1774776394),
				(75,2652871518),
				(76,566650946),
				(77,4142492826),
				(78,1728879713),
				(79,2882767088),
				(80,1783734482),
				(81,3629395816),
				(82,2517608232),
				(83,2874225571),
				(84,1861159788),
				(85,326777828),
				(86,3124490320),
				(87,2130389656),
				(88,2716951837),
				(89,967770486),
				(90,1724537150),
				(91,2185432712),
				(92,2364442137),
				(93,1164943284),
				(94,2105845187),
				(95,998989502),
				(96,3765401048),
				(97,2244026483),
				(98,1075463327),
				(99,1455516326),
				(100,1322494562),
				(101,910128902),
				(102,469688178),
				(103,1117454909),
				(104,936433444),
				(105,3490320968),
				(106,3675253459),
				(107,1240580251),
				(108,122909385),
				(109,2157517691),
				(110,634681816),
				(111,4142456567),
				(112,3825094682),
				(113,3061402683),
				(114,2540495037),
				(115,79693498),
				(116,3249098678),
				(117,1084186820),
				(118,1583128258),
				(119,426386531),
				(120,1761308591),
				(121,1047286709),
				(122,322548459),
				(123,995290223),
				(124,1845252383),
				(125,2603652396),
				(126,3431023940),
				(127,2942221577),
				(128,3202600964),
				(129,3727903485),
				(130,1712269319),
				(131,422464435),
				(132,3234572375),
				(133,1170764815),
				(134,3523960633),
				(135,3117677531),
				(136,1434042557),
				(137,442511882),
				(138,3600875718),
				(139,1076654713),
				(140,1738483198),
				(141,4213154764),
				(142,2393238008),
				(143,3677496056),
				(144,1014306527),
				(145,4251020053),
				(146,793779912),
				(147,2902807211),
				(148,842905082),
				(149,4246964064),
				(150,1395751752),
				(151,1040244610),
				(152,2656851899),
				(153,3396308128),
				(154,445077038),
				(155,3742853595),
				(156,3577915638),
				(157,679411651),
				(158,2892444358),
				(159,2354009459),
				(160,1767581616),
				(161,3150600392),
				(162,3791627101),
				(163,3102740896),
				(164,284835224),
				(165,4246832056),
				(166,1258075500),
				(167,768725851),
				(168,2589189241),
				(169,3069724005),
				(170,3532540348),
				(171,1274779536),
				(172,3789419226),
				(173,2764799539),
				(174,1660621633),
				(175,3471099624),
				(176,4011903706),
				(177,913787905),
				(178,3497959166),
				(179,737222580),
				(180,2514213453),
				(181,2928710040),
				(182,3937242737),
				(183,1804850592),
				(184,3499020752),
				(185,2949064160),
				(186,2386320175),
				(187,2390070455),
				(188,2415321851),
				(189,4061277028),
				(190,2290661394),
				(191,2416832540),
				(192,1336762016),
				(193,1754252060),
				(194,3520065937),
				(195,3014181293),
				(196,791618072),
				(197,3188594551),
				(198,3933548030),
				(199,2332172193),
				(200,3852520463),
				(201,3043980520),
				(202,413987798),
				(203,3465142937),
				(204,3030929376),
				(205,4245938359),
				(206,2093235073),
				(207,3534596313),
				(208,375366246),
				(209,2157278981),
				(210,2479649556),
				(211,555357303),
				(212,3870105701),
				(213,2008414854),
				(214,3344188149),
				(215,4221384143),
				(216,3956125452),
				(217,2067696032),
				(218,3594591187),
				(219,2921233993),
				(220,2428461),
				(221,544322398),
				(222,577241275),
				(223,1471733935),
				(224,610547355),
				(225,4027169054),
				(226,1432588573),
				(227,1507829418),
				(228,2025931657),
				(229,3646575487),
				(230,545086370),
				(231,48609733),
				(232,2200306550),
				(233,1653985193),
				(234,298326376),
				(235,1316178497),
				(236,3007786442),
				(237,2064951626),
				(238,458293330),
				(239,2589141269),
				(240,3591329599),
				(241,3164325604),
				(242,727753846),
				(243,2179363840),
				(244,146436021),
				(245,1461446943),
				(246,4069977195),
				(247,705550613),
				(248,3059967265),
				(249,3887724982),
				(250,4281599278),
				(251,3313849956),
				(252,1404054877),
				(253,2845806497),
				(254,146425753),
				(255,1854211946);

	INSERT INTO S1
		VALUES	(0,1266315497),
				(1,3048417604),
				(2,3681880366),
				(3,3289982499),
				(4,2909710000),
				(5,1235738493),
				(6,2632868024),
				(7,2414719590),
				(8,3970600049),
				(9,1771706367),
				(10,1449415276),
				(11,3266420449),
				(12,422970021),
				(13,1963543593),
				(14,2690192192),
				(15,3826793022),
				(16,1062508698),
				(17,1531092325),
				(18,1804592342),
				(19,2583117782),
				(20,2714934279),
				(21,4024971509),
				(22,1294809318),
				(23,4028980673),
				(24,1289560198),
				(25,2221992742),
				(26,1669523910),
				(27,35572830),
				(28,157838143),
				(29,1052438473),
				(30,1016535060),
				(31,1802137761),
				(32,1753167236),
				(33,1386275462),
				(34,3080475397),
				(35,2857371447),
				(36,1040679964),
				(37,2145300060),
				(38,2390574316),
				(39,1461121720),
				(40,2956646967),
				(41,4031777805),
				(42,4028374788),
				(43,33600511),
				(44,2920084762),
				(45,1018524850),
				(46,629373528),
				(47,3691585981),
				(48,3515945977),
				(49,2091462646),
				(50,2486323059),
				(51,586499841),
				(52,988145025),
				(53,935516892),
				(54,3367335476),
				(55,2599673255),
				(56,2839830854),
				(57,265290510),
				(58,3972581182),
				(59,2759138881),
				(60,3795373465),
				(61,1005194799),
				(62,847297441),
				(63,406762289),
				(64,1314163512),
				(65,1332590856),
				(66,1866599683),
				(67,4127851711),
				(68,750260880),
				(69,613907577),
				(70,1450815602),
				(71,3165620655),
				(72,3734664991),
				(73,3650291728),
				(74,3012275730),
				(75,3704569646),
				(76,1427272223),
				(77,778793252),
				(78,1343938022),
				(79,2676280711),
				(80,2052605720),
				(81,1946737175),
				(82,3164576444),
				(83,3914038668),
				(84,3967478842),
				(85,3682934266),
				(86,1661551462),
				(87,3294938066),
				(88,4011595847),
				(89,840292616),
				(90,3712170807),
				(91,616741398),
				(92,312560963),
				(93,711312465),
				(94,1351876610),
				(95,322626781),
				(96,1910503582),
				(97,271666773),
				(98,2175563734),
				(99,1594956187),
				(100,70604529),
				(101,3617834859),
				(102,1007753275),
				(103,1495573769),
				(104,4069517037),
				(105,2549218298),
				(106,2663038764),
				(107,504708206),
				(108,2263041392),
				(109,3941167025),
				(110,2249088522),
				(111,1514023603),
				(112,1998579484),
				(113,1312622330),
				(114,694541497),
				(115,2582060303),
				(116,2151582166),
				(117,1382467621),
				(118,776784248),
				(119,2618340202),
				(120,3323268794),
				(121,2497899128),
				(122,2784771155),
				(123,503983604),
				(124,4076293799),
				(125,907881277),
				(126,423175695),
				(127,432175456),
				(128,1378068232),
				(129,4145222326),
				(130,3954048622),
				(131,3938656102),
				(132,3820766613),
				(133,2793130115),
				(134,2977904593),
				(135,26017576),
				(136,3274890735),
				(137,3194772133),
				(138,1700274565),
				(139,1756076034),
				(140,4006520079),
				(141,3677328699),
				(142,720338349),
				(143,1533947780),
				(144,354530856),
				(145,688349552),
				(146,3973924725),
				(147,1637815568),
				(148,332179504),
				(149,3949051286),
				(150,53804574),
				(151,2852348879),
				(152,3044236432),
				(153,1282449977),
				(154,3583942155),
				(155,3416972820),
				(156,4006381244),
				(157,1617046695),
				(158,2628476075),
				(159,3002303598),
				(160,1686838959),
				(161,431878346),
				(162,2686675385),
				(163,1700445008),
				(164,1080580658),
				(165,1009431731),
				(166,832498133),
				(167,3223435511),
				(168,2605976345),
				(169,2271191193),
				(170,2516031870),
				(171,1648197032),
				(172,4164389018),
				(173,2548247927),
				(174,300782431),
				(175,375919233),
				(176,238389289),
				(177,3353747414),
				(178,2531188641),
				(179,2019080857),
				(180,1475708069),
				(181,455242339),
				(182,2609103871),
				(183,448939670),
				(184,3451063019),
				(185,1395535956),
				(186,2413381860),
				(187,1841049896),
				(188,1491858159),
				(189,885456874),
				(190,4264095073),
				(191,4001119347),
				(192,1565136089),
				(193,3898914787),
				(194,1108368660),
				(195,540939232),
				(196,1173283510),
				(197,2745871338),
				(198,3681308437),
				(199,4207628240),
				(200,3343053890),
				(201,4016749493),
				(202,1699691293),
				(203,1103962373),
				(204,3625875870),
				(205,2256883143),
				(206,3830138730),
				(207,1031889488),
				(208,3479347698),
				(209,1535977030),
				(210,4236805024),
				(211,3251091107),
				(212,2132092099),
				(213,1774941330),
				(214,1199868427),
				(215,1452454533),
				(216,157007616),
				(217,2904115357),
				(218,342012276),
				(219,595725824),
				(220,1480756522),
				(221,206960106),
				(222,497939518),
				(223,591360097),
				(224,863170706),
				(225,2375253569),
				(226,3596610801),
				(227,1814182875),
				(228,2094937945),
				(229,3421402208),
				(230,1082520231),
				(231,3463918190),
				(232,2785509508),
				(233,435703966),
				(234,3908032597),
				(235,1641649973),
				(236,2842273706),
				(237,3305899714),
				(238,1510255612),
				(239,2148256476),
				(240,2655287854),
				(241,3276092548),
				(242,4258621189),
				(243,236887753),
				(244,3681803219),
				(245,274041037),
				(246,1734335097),
				(247,3815195456),
				(248,3317970021),
				(249,1899903192),
				(250,1026095262),
				(251,4050517792),
				(252,356393447),
				(253,2410691914),
				(254,3873677099),
				(255,3682840055);

	INSERT INTO S2
		VALUES	(0,3913112168),
				(1,2491498743),
				(2,4132185628),
				(3,2489919796),
				(4,1091903735),
				(5,1979897079),
				(6,3170134830),
				(7,3567386728),
				(8,3557303409),
				(9,857797738),
				(10,1136121015),
				(11,1342202287),
				(12,507115054),
				(13,2535736646),
				(14,337727348),
				(15,3213592640),
				(16,1301675037),
				(17,2528481711),
				(18,1895095763),
				(19,1721773893),
				(20,3216771564),
				(21,62756741),
				(22,2142006736),
				(23,835421444),
				(24,2531993523),
				(25,1442658625),
				(26,3659876326),
				(27,2882144922),
				(28,676362277),
				(29,1392781812),
				(30,170690266),
				(31,3921047035),
				(32,1759253602),
				(33,3611846912),
				(34,1745797284),
				(35,664899054),
				(36,1329594018),
				(37,3901205900),
				(38,3045908486),
				(39,2062866102),
				(40,2865634940),
				(41,3543621612),
				(42,3464012697),
				(43,1080764994),
				(44,553557557),
				(45,3656615353),
				(46,3996768171),
				(47,991055499),
				(48,499776247),
				(49,1265440854),
				(50,648242737),
				(51,3940784050),
				(52,980351604),
				(53,3713745714),
				(54,1749149687),
				(55,3396870395),
				(56,4211799374),
				(57,3640570775),
				(58,1161844396),
				(59,3125318951),
				(60,1431517754),
				(61,545492359),
				(62,4268468663),
				(63,3499529547),
				(64,1437099964),
				(65,2702547544),
				(66,3433638243),
				(67,2581715763),
				(68,2787789398),
				(69,1060185593),
				(70,1593081372),
				(71,2418618748),
				(72,4260947970),
				(73,69676912),
				(74,2159744348),
				(75,86519011),
				(76,2512459080),
				(77,3838209314),
				(78,1220612927),
				(79,3339683548),
				(80,133810670),
				(81,1090789135),
				(82,1078426020),
				(83,1569222167),
				(84,845107691),
				(85,3583754449),
				(86,4072456591),
				(87,1091646820),
				(88,628848692),
				(89,1613405280),
				(90,3757631651),
				(91,526609435),
				(92,236106946),
				(93,48312990),
				(94,2942717905),
				(95,3402727701),
				(96,1797494240),
				(97,859738849),
				(98,992217954),
				(99,4005476642),
				(100,2243076622),
				(101,3870952857),
				(102,3732016268),
				(103,765654824),
				(104,3490871365),
				(105,2511836413),
				(106,1685915746),
				(107,3888969200),
				(108,1414112111),
				(109,2273134842),
				(110,3281911079),
				(111,4080962846),
				(112,172450625),
				(113,2569994100),
				(114,980381355),
				(115,4109958455),
				(116,2819808352),
				(117,2716589560),
				(118,2568741196),
				(119,3681446669),
				(120,3329971472),
				(121,1835478071),
				(122,660984891),
				(123,3704678404),
				(124,4045999559),
				(125,3422617507),
				(126,3040415634),
				(127,1762651403),
				(128,1719377915),
				(129,3470491036),
				(130,2693910283),
				(131,3642056355),
				(132,3138596744),
				(133,1364962596),
				(134,2073328063),
				(135,1983633131),
				(136,926494387),
				(137,3423689081),
				(138,2150032023),
				(139,4096667949),
				(140,1749200295),
				(141,3328846651),
				(142,309677260),
				(143,2016342300),
				(144,1779581495),
				(145,3079819751),
				(146,111262694),
				(147,1274766160),
				(148,443224088),
				(149,298511866),
				(150,1025883608),
				(151,3806446537),
				(152,1145181785),
				(153,168956806),
				(154,3641502830),
				(155,3584813610),
				(156,1689216846),
				(157,3666258015),
				(158,3200248200),
				(159,1692713982),
				(160,2646376535),
				(161,4042768518),
				(162,1618508792),
				(163,1610833997),
				(164,3523052358),
				(165,4130873264),
				(166,2001055236),
				(167,3610705100),
				(168,2202168115),
				(169,4028541809),
				(170,2961195399),
				(171,1006657119),
				(172,2006996926),
				(173,3186142756),
				(174,1430667929),
				(175,3210227297),
				(176,1314452623),
				(177,4074634658),
				(178,4101304120),
				(179,2273951170),
				(180,1399257539),
				(181,3367210612),
				(182,3027628629),
				(183,1190975929),
				(184,2062231137),
				(185,2333990788),
				(186,2221543033),
				(187,2438960610),
				(188,1181637006),
				(189,548689776),
				(190,2362791313),
				(191,3372408396),
				(192,3104550113),
				(193,3145860560),
				(194,296247880),
				(195,1970579870),
				(196,3078560182),
				(197,3769228297),
				(198,1714227617),
				(199,3291629107),
				(200,3898220290),
				(201,166772364),
				(202,1251581989),
				(203,493813264),
				(204,448347421),
				(205,195405023),
				(206,2709975567),
				(207,677966185),
				(208,3703036547),
				(209,1463355134),
				(210,2715995803),
				(211,1338867538),
				(212,1343315457),
				(213,2802222074),
				(214,2684532164),
				(215,233230375),
				(216,2599980071),
				(217,2000651841),
				(218,3277868038),
				(219,1638401717),
				(220,4028070440),
				(221,3237316320),
				(222,6314154),
				(223,819756386),
				(224,300326615),
				(225,590932579),
				(226,1405279636),
				(227,3267499572),
				(228,3150704214),
				(229,2428286686),
				(230,3959192993),
				(231,3461946742),
				(232,1862657033),
				(233,1266418056),
				(234,963775037),
				(235,2089974820),
				(236,2263052895),
				(237,1917689273),
				(238,448879540),
				(239,3550394620),
				(240,3981727096),
				(241,150775221),
				(242,3627908307),
				(243,1303187396),
				(244,508620638),
				(245,2975983352),
				(246,2726630617),
				(247,1817252668),
				(248,1876281319),
				(249,1457606340),
				(250,908771278),
				(251,3720792119),
				(252,3617206836),
				(253,2455994898),
				(254,1729034894),
				(255,1080033504);

	INSERT INTO S3
		VALUES	(0,976866871),
				(1,3556439503),
				(2,2881648439),
				(3,1522871579),
				(4,1555064734),
				(5,1336096578),
				(6,3548522304),
				(7,2579274686),
				(8,3574697629),
				(9,3205460757),
				(10,3593280638),
				(11,3338716283),
				(12,3079412587),
				(13,564236357),
				(14,2993598910),
				(15,1781952180),
				(16,1464380207),
				(17,3163844217),
				(18,3332601554),
				(19,1699332808),
				(20,1393555694),
				(21,1183702653),
				(22,3581086237),
				(23,1288719814),
				(24,691649499),
				(25,2847557200),
				(26,2895455976),
				(27,3193889540),
				(28,2717570544),
				(29,1781354906),
				(30,1676643554),
				(31,2592534050),
				(32,3230253752),
				(33,1126444790),
				(34,2770207658),
				(35,2633158820),
				(36,2210423226),
				(37,2615765581),
				(38,2414155088),
				(39,3127139286),
				(40,673620729),
				(41,2805611233),
				(42,1269405062),
				(43,4015350505),
				(44,3341807571),
				(45,4149409754),
				(46,1057255273),
				(47,2012875353),
				(48,2162469141),
				(49,2276492801),
				(50,2601117357),
				(51,993977747),
				(52,3918593370),
				(53,2654263191),
				(54,753973209),
				(55,36408145),
				(56,2530585658),
				(57,25011837),
				(58,3520020182),
				(59,2088578344),
				(60,530523599),
				(61,2918365339),
				(62,1524020338),
				(63,1518925132),
				(64,3760827505),
				(65,3759777254),
				(66,1202760957),
				(67,3985898139),
				(68,3906192525),
				(69,674977740),
				(70,4174734889),
				(71,2031300136),
				(72,2019492241),
				(73,3983892565),
				(74,4153806404),
				(75,3822280332),
				(76,352677332),
				(77,2297720250),
				(78,60907813),
				(79,90501309),
				(80,3286998549),
				(81,1016092578),
				(82,2535922412),
				(83,2839152426),
				(84,457141659),
				(85,509813237),
				(86,4120667899),
				(87,652014361),
				(88,1966332200),
				(89,2975202805),
				(90,55981186),
				(91,2327461051),
				(92,676427537),
				(93,3255491064),
				(94,2882294119),
				(95,3433927263),
				(96,1307055953),
				(97,942726286),
				(98,933058658),
				(99,2468411793),
				(100,3933900994),
				(101,4215176142),
				(102,1361170020),
				(103,2001714738),
				(104,2830558078),
				(105,3274259782),
				(106,1222529897),
				(107,1679025792),
				(108,2729314320),
				(109,3714953764),
				(110,1770335741),
				(111,151462246),
				(112,3013232138),
				(113,1682292957),
				(114,1483529935),
				(115,471910574),
				(116,1539241949),
				(117,458788160),
				(118,3436315007),
				(119,1807016891),
				(120,3718408830),
				(121,978976581),
				(122,1043663428),
				(123,3165965781),
				(124,1927990952),
				(125,4200891579),
				(126,2372276910),
				(127,3208408903),
				(128,3533431907),
				(129,1412390302),
				(130,2931980059),
				(131,4132332400),
				(132,1947078029),
				(133,3881505623),
				(134,4168226417),
				(135,2941484381),
				(136,1077988104),
				(137,1320477388),
				(138,886195818),
				(139,18198404),
				(140,3786409000),
				(141,2509781533),
				(142,112762804),
				(143,3463356488),
				(144,1866414978),
				(145,891333506),
				(146,18488651),
				(147,661792760),
				(148,1628790961),
				(149,3885187036),
				(150,3141171499),
				(151,876946877),
				(152,2693282273),
				(153,1372485963),
				(154,791857591),
				(155,2686433993),
				(156,3759982718),
				(157,3167212022),
				(158,3472953795),
				(159,2716379847),
				(160,445679433),
				(161,3561995674),
				(162,3504004811),
				(163,3574258232),
				(164,54117162),
				(165,3331405415),
				(166,2381918588),
				(167,3769707343),
				(168,4154350007),
				(169,1140177722),
				(170,4074052095),
				(171,668550556),
				(172,3214352940),
				(173,367459370),
				(174,261225585),
				(175,2610173221),
				(176,4209349473),
				(177,3468074219),
				(178,3265815641),
				(179,314222801),
				(180,3066103646),
				(181,3808782860),
				(182,282218597),
				(183,3406013506),
				(184,3773591054),
				(185,379116347),
				(186,1285071038),
				(187,846784868),
				(188,2669647154),
				(189,3771962079),
				(190,3550491691),
				(191,2305946142),
				(192,453669953),
				(193,1268987020),
				(194,3317592352),
				(195,3279303384),
				(196,3744833421),
				(197,2610507566),
				(198,3859509063),
				(199,266596637),
				(200,3847019092),
				(201,517658769),
				(202,3462560207),
				(203,3443424879),
				(204,370717030),
				(205,4247526661),
				(206,2224018117),
				(207,4143653529),
				(208,4112773975),
				(209,2788324899),
				(210,2477274417),
				(211,1456262402),
				(212,2901442914),
				(213,1517677493),
				(214,1846949527),
				(215,2295493580),
				(216,3734397586),
				(217,2176403920),
				(218,1280348187),
				(219,1908823572),
				(220,3871786941),
				(221,846861322),
				(222,1172426758),
				(223,3287448474),
				(224,3383383037),
				(225,1655181056),
				(226,3139813346),
				(227,901632758),
				(228,1897031941),
				(229,2986607138),
				(230,3066810236),
				(231,3447102507),
				(232,1393639104),
				(233,373351379),
				(234,950779232),
				(235,625454576),
				(236,3124240540),
				(237,4148612726),
				(238,2007998917),
				(239,544563296),
				(240,2244738638),
				(241,2330496472),
				(242,2058025392),
				(243,1291430526),
				(244,424198748),
				(245,50039436),
				(246,29584100),
				(247,3605783033),
				(248,2429876329),
				(249,2791104160),
				(250,1057563949),
				(251,3255363231),
				(252,3075367218),
				(253,3463963227),
				(254,1469046755),
				(255,985887462);

END




/*
(SELECT * FROM [dbo].[FNC_ENCIPHER](0x243f6a88,0x243f6a88))
(SELECT [dbo].[FNC_XOR](0x243f6a88,0x243f6a88))
(SELECT [dbo].[FNC_ROUND](0x243f6a88, 0x243f6a88, 1))
(SELECT [dbo].[WORDBYTE0](0x243f6a88))


	select * FROM P;
	select * FROM S0;
	select * FROM S1;
	select * FROM S2;
	select * FROM S3;
*/


	/*
	DECLARE @J		INT = 5;
	SELECT (@J)%LEN('sadasd')
	SELECT LEN('sadasd')
	DECLARE @J		INT = 3;
	SELECT ASCII(SUBSTRING('sadasd',(@J + 1),1))
	SELECT ASCII(SUBSTRING('sadasd',(@J + 2)%LEN('sadasd'),1))
	SELECT ASCII(SUBSTRING('sadasd',(@J + 3)%LEN('sadasd'),1))
	SELECT * FROM P

	DECLARE @J		INT = 5,
			@GUARD	BIGINT,
			@Key	VARCHAR(MAX) = 'sadasd';
	SET @GUARD = 
	(
		(
			ASCII(SUBSTRING(@Key,@J%LEN(@Key),1))
			*256+ASCII(SUBSTRING(@Key,6,1))
		)
		*256+ASCII(SUBSTRING(@Key,(@J + 2)%LEN(@Key),1))
	)
	*256+ASCII(SUBSTRING(@Key,(@J + 3)%LEN(@Key),1))
	SELECT @GUARD
	EXEC [dbo].[PRC_PrepareCrypt] 'sadasd'
	*/