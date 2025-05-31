USE [Argentum3]
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE ReadAllReagents
	-- Add the parameters for the stored procedure here
AS
BEGIN
	SELECT Р.[НазваниеРеагента]
		   ,Р.[CAS]
           ,Р.[МестоНаСкладе]
		   ,СК.[Количество]
		   ,СЕИ.[КороткоеНазваниеЕдИзм]
		   ,ССР.[СтатусРеагента]
           ,Р.[ВнешнийВид]
           ,Р.[КлассСоединения]
           ,Р.[Примечание]
           ,Р.[Формула]
	FROM Реагенты AS Р
	INNER JOIN СловарьКоличества AS СК
		ON Р.КодРеагента = СК.КодРеагента
	INNER JOIN СловарьЕдиницИзмерения AS СЕИ
		ON СК.КодЕдИзмерения = СЕИ.КодЕдИзмерения
	INNER JOIN СловарьСтатусаРеагентов AS ССР
		ON СК.КодСтатусаРеагента = ССР.КодСтатусаРеагента
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE SearchReagent 
	-- Add the parameters for the stored procedure here
	@Param1 nvarchar(100)
AS
BEGIN
	SELECT Р.КодРеагента
		   ,Р.[НазваниеРеагента]
		   ,Р.[CAS]
           ,Р.[МестоНаСкладе]
		   ,СК.[Количество]
		   ,СЕИ.[КороткоеНазваниеЕдИзм]
		   ,ССР.[СтатусРеагента]
           ,Р.[ВнешнийВид]
           ,Р.[КлассСоединения]
           ,Р.[Примечание]
           ,Р.[Формула]
	FROM Реагенты AS Р
	INNER JOIN СловарьКоличества AS СК
		ON Р.КодРеагента = СК.КодРеагента
	INNER JOIN СловарьЕдиницИзмерения AS СЕИ
		ON СК.КодЕдИзмерения = СЕИ.КодЕдИзмерения
	INNER JOIN СловарьСтатусаРеагентов AS ССР
		ON СК.КодСтатусаРеагента = ССР.КодСтатусаРеагента 
	WHERE Р.CAS = @Param1 OR Р.НазваниеРеагента LIKE @Param1 + N'%'
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE AllStatus 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	SELECT СтатусРеагента
	FROM СловарьСтатусаРеагентов
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE AllMeasures 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	SELECT КороткоеНазваниеЕдИзм
	FROM СловарьЕдиницИзмерения
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE AddReagent
    @НазваниеРеагента NVARCHAR(256),
    @CAS NVARCHAR(64) = NULL,
    @МестоНаСкладе NVARCHAR(256) = NULL,
    @ВнешнийВид NVARCHAR(256) = '',
    @КлассСоединения NVARCHAR(128) = '',
    @Примечание NVARCHAR(512) = '',
    @Ссылка NVARCHAR(512) = '',
    @Формула NVARCHAR(64) = '',
    @Количество FLOAT,
    @ЕдИзмерения NVARCHAR(16),
    @СтатусРеагента NVARCHAR(32) = 'много'
AS
BEGIN
    DECLARE @КодЕдИзмерения INT;
	DECLARE @КодСтатусаРеагента INT;

    SELECT @КодЕдИзмерения = КодЕдИзмерения
    FROM СловарьЕдиницИзмерения
    WHERE КороткоеНазваниеЕдИзм = @ЕдИзмерения;

    IF @КодЕдИзмерения IS NULL
    BEGIN
        RAISERROR('Единица измерения не найдена', 16, 1);
        RETURN;
    END

	SELECT @КодСтатусаРеагента = КодСтатусаРеагента
    FROM СловарьСтатусаРеагентов
    WHERE СтатусРеагента = @СтатусРеагента;

    IF @КодЕдИзмерения IS NULL
    BEGIN
        RAISERROR('Статус реактива не найден', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    INSERT INTO Реагенты (
        НазваниеРеагента, CAS, МестоНаСкладе, ВнешнийВид,
        КлассСоединения, Примечание, Ссылка, Формула
    )
    VALUES (
        @НазваниеРеагента, @CAS, @МестоНаСкладе, @ВнешнийВид,
        @КлассСоединения, @Примечание, @Ссылка, @Формула
    );

    DECLARE @КодРеагента INT = SCOPE_IDENTITY();

    INSERT INTO СловарьКоличества (
        КодРеагента, Количество, КодЕдИзмерения, КодСтатусаРеагента
    )
    VALUES (
        @КодРеагента, @Количество, @КодЕдИзмерения, @КодСтатусаРеагента
    );

    COMMIT;
END;
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE CorrectReagentInformation
	-- Add the parameters for the stored procedure here
	@Param1 int
AS
BEGIN
	SELECT Р.[НазваниеРеагента]
		   ,Р.[CAS]
           ,Р.[МестоНаСкладе]
		   ,СК.[Количество]
		   ,СЕИ.[КороткоеНазваниеЕдИзм]
		   ,ССР.[СтатусРеагента]
           ,Р.[ВнешнийВид]
           ,Р.[КлассСоединения]
           ,Р.[Примечание]
           ,Р.[Формула]
	FROM Реагенты AS Р
	INNER JOIN СловарьКоличества AS СК
		ON Р.КодРеагента = СК.КодРеагента
	INNER JOIN СловарьЕдиницИзмерения AS СЕИ
		ON СК.КодЕдИзмерения = СЕИ.КодЕдИзмерения
	INNER JOIN СловарьСтатусаРеагентов AS ССР
		ON СК.КодСтатусаРеагента = ССР.КодСтатусаРеагента  
	WHERE Р.КодРеагента = @Param1
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE ProcUpdateField
    @ID INT,
    @ИмяПоля NVARCHAR(128),
    @НовоеЗначение NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    -- Проверка на существование поля
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Реагенты' AND COLUMN_NAME = @ИмяПоля
    )
    BEGIN
        RAISERROR('Поле %s не существует в таблице Реагенты.', 16, 1, @ИмяПоля)
        RETURN
    END

    -- Делаем запрос и выполняем его
    DECLARE @Sql NVARCHAR(MAX)
    SET @Sql = '
        UPDATE Реагенты
        SET [' + @ИмяПоля + '] = @НовоеЗначение
        WHERE КодРеагента = @ID
    '

    EXEC sp_executesql @Sql,
        N'@ID INT, @НовоеЗначение NVARCHAR(512)',
        @ID = @ID, @НовоеЗначение = @НовоеЗначение
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE ProcUpdateFieldU
    @ID INT,
    @ИмяПоля NVARCHAR(128),
    @НовоеЗначение NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    -- Проверка на существование поля
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Пользователи' AND COLUMN_NAME = @ИмяПоля
    )
    BEGIN
        RAISERROR('Поле %s не существует в таблице Пользователи.', 16, 1, @ИмяПоля)
        RETURN
    END

    -- Делаем запрос и выполняем его
    DECLARE @Sql NVARCHAR(MAX)
    SET @Sql = '
        UPDATE Пользователи
        SET [' + @ИмяПоля + '] = @НовоеЗначение
        WHERE КодПользователя = @ID
    '

    EXEC sp_executesql @Sql,
        N'@ID INT, @НовоеЗначение NVARCHAR(512)',
        @ID = @ID, @НовоеЗначение = @НовоеЗначение
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE GetUserIdByLogin
    @Login NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 КодПользователя
    FROM Пользователи
    WHERE Имя = @Login
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE LogChange
    @КодПользователя INT,
    @ИмяТаблицы NVARCHAR(32),
    @ТипОперации NVARCHAR(16),
    @ИзменённоеПоле NVARCHAR(32),
    @ПолеДо NVARCHAR(32),
    @ПолеПосле NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ЖурналИзменений (
        КодПользователя,
        ДатаИзменения,
        ИмяТаблицы,
        ТипОперации,
        ИзменённоеПоле,
        ПолеДо,
        ПолеПосле
    )
    VALUES (
        @КодПользователя,
        GETDATE(),
        @ИмяТаблицы,
        @ТипОперации,
        @ИзменённоеПоле,
        @ПолеДо,
        @ПолеПосле
    )
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE OrderList
	-- Add the parameters for the stored procedure here
AS
BEGIN
	SELECT Р.[НазваниеРеагента]
		   ,Р.[CAS]
		   ,'' AS Количество
	FROM Реагенты AS Р
	INNER JOIN СловарьКоличества AS СК
		ON Р.КодРеагента = СК.КодРеагента
	WHERE СК.[Количество] = 0 OR СК.КодСтатусаРеагента = 1
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE ReadAllUsers
	-- Add the parameters for the stored procedure here
AS
BEGIN
	SELECT Имя
		   ,Фамилия
		   ,Пароль
		   ,Статус
	FROM Пользователи
END
GO

-- ===============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ===============================================
CREATE OR ALTER PROCEDURE CorrectUserInformation_1
	-- Add the parameters for the stored procedure here
	@Инфо NVARCHAR(32)
AS
BEGIN
	SELECT КодПользователя
		   ,Имя
		   ,Фамилия
		   ,Пароль
		   ,Статус
	FROM Пользователи  
	WHERE Имя LIKE @Инфо + N'%' OR Фамилия LIKE @Инфо + N'%'
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE SearchUser 
	-- Add the parameters for the stored procedure here
	@Param1 NVARCHAR(32)
AS
BEGIN
	SELECT Имя
		   ,Фамилия
		   ,Пароль
		   ,Статус
	FROM Пользователи
	WHERE Имя LIKE @Param1 + N'%' OR Фамилия LIKE @Param1 + N'%'
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE ReadLog 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	SELECT ЖИ.ID
		   ,П.Фамилия AS 'Кто_Внёс_Изменения'
		   ,ЖИ.ДатаИзменения
		   ,ЖИ.ТипОперации
		   ,ЖИ.ИмяТаблицы
		   ,ЖИ.ИзменённоеПоле
		   ,ЖИ.ПолеДо
		   ,ЖИ.ПолеПосле
	FROM ЖурналИзменений AS ЖИ
	INNER JOIN Пользователи AS П
		ON ЖИ.КодПользователя = П.КодПользователя
END