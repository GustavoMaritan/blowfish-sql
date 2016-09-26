SELECT 0x243f6a88 AS Item
	INTO #P

INSERT INTO #P(Item) 
	VALUES (0x85a308d3),
			(0x13198a2e),
			(0x03707344),
			(0xa4093822),
			(0x299f31d0),
			(0x082efa98),
			(0xec4e6c89),
			(0x452821e6),
			(0x38d01377),
			(0xbe5466cf),
			(0x34e90c6c),
			(0xc0ac29b7),
			(0xc97c50dd),
			(0x3f84d5b5),
			(0xb5470917),
			(0x9216d5d9),
			(0x8979fb1b)


select Cast('0x85a308d3' as varbinary(4))

SELECT CONVERT(VARBINARY(10), '0x85a308d3', 1);
GO











CREATE FUNCTION xor(@v varbinary,@v2 varbinary)
	returnS int
as 
begin

	DECLARE @R int = POWER(@v,@v2)
	if @R < 0
		SET @R = 0xffffffff + 1 + @R;

	RETURN @R;

end
GO




DECLARE @what sql_variant
DECLARE @foo decimal(19,3) = 1, @bar decimal(11,7) = 2

SELECT @what = 0xffffffff
SELECT
    SQL_VARIANT_PROPERTY(@what, 'BaseType'),
    SQL_VARIANT_PROPERTY(@what, 'Precision'),
    SQL_VARIANT_PROPERTY(@what, 'Scale'),
    SQL_VARIANT_PROPERTY(@what, 'MaxLength')
