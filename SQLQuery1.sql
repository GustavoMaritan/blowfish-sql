SELECT 
	--TABLE_NAME, 
	COLUMN_NAME AS Name, 
	--COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + '.' + TABLE_NAME),COLUMN_NAME, 'ColumnID') AS COLUMN_ID,
	DATA_TYPE AS Type,
	NUMERIC_PRECISION AS MaxPrec,
	NUMERIC_PRECISION_RADIX AS Radix,
	CHARACTER_MAXIMUM_LENGTH AS CharLength,
	IS_NULLABLE AS Nullable,
	NUMERIC_SCALE
FROM LoteriaFederal12.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Descontos';

exec SP_BuscaUser