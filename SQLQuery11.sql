DROP PROCEDURE PRC_PrepareCrypt
GO

CREATE PROCEDURE PRC_PrepareCrypt
	@Key	varchar(max)
AS 

BEGIN

	SET @Key = (SELECT [dbo].[FNC_CHAVE](@Key))

	EXEC [dbo].[PRC_INSERTVALUES]


	DECLARE @J		INT = 1,
			@I		INT = 0,
			@GUARD	INT,
			@X		BIGINT,
			@J1		INT,
			@J2		INT,
			@J3		INT;
			
	DECLARE @tteste table(valuef int)

	WHILE @I < 18
		BEGIN
			IF (@J + 1)%LEN(@Key) = 0
				SET @J1 = (@J + 1)
			ELSE
				SET @J1 = (@J + 1)%LEN(@Key)
			IF (@J + 2)%LEN(@Key) = 0
				SET @J2 = (@J + 2)
			ELSE
				SET @J2 = (@J + 2)%LEN(@Key)
			IF (@J + 3)%LEN(@Key) = 0
				SET @J3 = (@J + 3)
			ELSE
				SET @J3 = (@J + 3)%LEN(@Key)

			SET @GUARD = 
				(
					(
						ASCII(SUBSTRING(@Key,@J%LEN(@Key),1))
						*256+ASCII(SUBSTRING(@Key,@J1,1))--
					)
					*256+ASCII(SUBSTRING(@Key,@J2,1))--
				)
				*256+ASCII(SUBSTRING(@Key,@J3,1))--

			insert into @tteste values(@GUARD)
			SELECT @X = [dbo].[FNC_XOR]((SELECT Value FROM P WHERE Indice = @I),@GUARD);

			UPDATE P
				SET VALUE = @X
				WHERE Indice = @I

			SET @J= (@J+4)%LEN(@Key);
			SET @I += 1
		END

	--return

	DECLARE @XL_PAR BIGINT = 0,
			@XR_PAR BIGINT = 0;
	SET @I = 0;

	WHILE @I < 18
		BEGIN
			SELECT @XL_PAR = v1,@XR_PAR = v2 FROM [dbo].[FNC_ENCIPHER](@XL_PAR,@XR_PAR)
			UPDATE P
				SET VALUE = @XL_PAR
				WHERE Indice = @I

			UPDATE P
				SET VALUE = @XR_PAR
				WHERE Indice = @I + 1
			SET @I += 2
		END
	
	/*
		EXEC [dbo].[PRC_PrepareCrypt] 'sadasd'
	*/
	--SELECT * FROM P
	--return

	SET @J = 0;
	WHILE @J < 256
		BEGIN
			SELECT @XL_PAR = v1,@XR_PAR = v2 FROM [dbo].[FNC_ENCIPHER](@XL_PAR,@XR_PAR)

			UPDATE S0
				SET VALUE = @XL_PAR
				WHERE Indice = @J

			UPDATE S0
				SET VALUE = @XR_PAR
				WHERE Indice = @J + 1

			SET @J += 2
		END
	
	SET @J = 0;
	WHILE @J < 256
		BEGIN
			SELECT @XL_PAR = v1,@XR_PAR = v2 FROM [dbo].[FNC_ENCIPHER](@XL_PAR,@XR_PAR)

			UPDATE S1
				SET VALUE = @XL_PAR
				WHERE Indice = @J

			UPDATE S1
				SET VALUE = @XR_PAR
				WHERE Indice = @J + 1

			SET @J += 2
		END

	SET @J = 0;
	WHILE @J < 256
		BEGIN
			SELECT @XL_PAR = v1,@XR_PAR = v2 FROM [dbo].[FNC_ENCIPHER](@XL_PAR,@XR_PAR)

			UPDATE S2
				SET VALUE = @XL_PAR
				WHERE Indice = @J

			UPDATE S2
				SET VALUE = @XR_PAR
				WHERE Indice = @J + 1

			SET @J += 2
		END

	SET @J = 0;
	WHILE @J < 256
		BEGIN
			SELECT @XL_PAR = v1,@XR_PAR = v2 FROM [dbo].[FNC_ENCIPHER](@XL_PAR,@XR_PAR)

			UPDATE S3
				SET VALUE = @XL_PAR
				WHERE Indice = @J

			UPDATE S3
				SET VALUE = @XR_PAR
				WHERE Indice = @J + 1

			SET @J += 2
		END

	select * FROM P;
	select * FROM S0;
	select * FROM S1;
	select * FROM S2;
	select * FROM S3;

END
GO

DROP PROCEDURE PRC_ENCRYPT
GO

CREATE PROCEDURE PRC_ENCRYPT
	@T		VARCHAR(200)
	--,@Ret	VARCHAR(MAX) OUTPUT
AS
/*
	EXEC [dbo].[PRC_PrepareCrypt] 'gustavo'
	EXEC [dbo].[PRC_ENCRYPT] 'asdasdasdasdas1'
*/
BEGIN
	DECLARE @F			INT,
			@TLENGTH	INT,
			@L			VARCHAR(MAX),
			@R			VARCHAR(MAX),
			@ENC		VARCHAR(MAX);
			
	WHILE @F < LEN(@T) % 8
		BEGIN
			SET @T = @T + '\u0000';
			SET @F += 1;
		END
	
	SET @F = 0;
	WHILE @F < LEN(@T)
		BEGIN
			SET @L = SUBSTRING(@T,@F + 1,4)
			SET @R = SUBSTRING(@T,@F + 5,4)

			DECLARE @lCALC BIGINT = (ASCII(SUBSTRING(@L, 4, 1)) 
			| (ASCII(SUBSTRING(@L, 3, 1)) * power(2,8))
			| (ASCII(SUBSTRING(@L, 2, 1)) * power(2,16))
			| (ASCII(SUBSTRING(@L, 1, 1)) * power(2,24)))
			DECLARE @rCALC BIGINT = (ASCII(SUBSTRING(@R, 4, 1)) 
			| (ASCII(SUBSTRING(@R, 3, 1)) * power(2,8))
			| (ASCII(SUBSTRING(@R, 2, 1)) * power(2,16))
			| (ASCII(SUBSTRING(@R, 1, 1)) * power(2,24)))

			IF @lCALC < 0
				SET @lCALC = 4294967295 + 1 + @lCALC
			IF @rCALC < 0
				SET @rCALC = 4294967295 + 1 + @rCALC

			SELECT @lCALC = v1,@rCALC = v2 FROM [dbo].[FNC_ENCIPHER](@lCALC,@rCALC)

			SET @ENC += ((SELECT [dbo].[FNC_WORDESCAPE](@lCALC)) + (SELECT [dbo].[FNC_WORDESCAPE](@rCALC)))

			SET @F += 8;
		END

		SELECT @ENC
		--SET @Ret = @ENC
		--RETURN @Ret
END
GO


