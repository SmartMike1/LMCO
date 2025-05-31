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
	SELECT �.[����������������]
		   ,�.[CAS]
           ,�.[�������������]
		   ,��.[����������]
		   ,���.[���������������������]
		   ,���.[��������������]
           ,�.[����������]
           ,�.[���������������]
           ,�.[����������]
           ,�.[�������]
	FROM �������� AS �
	INNER JOIN ����������������� AS ��
		ON �.����������� = ��.�����������
	INNER JOIN ���������������������� AS ���
		ON ��.�������������� = ���.��������������
	INNER JOIN ����������������������� AS ���
		ON ��.������������������ = ���.������������������
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
	SELECT �.�����������
		   ,�.[����������������]
		   ,�.[CAS]
           ,�.[�������������]
		   ,��.[����������]
		   ,���.[���������������������]
		   ,���.[��������������]
           ,�.[����������]
           ,�.[���������������]
           ,�.[����������]
           ,�.[�������]
	FROM �������� AS �
	INNER JOIN ����������������� AS ��
		ON �.����������� = ��.�����������
	INNER JOIN ���������������������� AS ���
		ON ��.�������������� = ���.��������������
	INNER JOIN ����������������������� AS ���
		ON ��.������������������ = ���.������������������ 
	WHERE �.CAS = @Param1 OR �.���������������� LIKE @Param1 + N'%'
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
	SELECT ��������������
	FROM �����������������������
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
	SELECT ���������������������
	FROM ����������������������
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE AddReagent
    @���������������� NVARCHAR(256),
    @CAS NVARCHAR(64) = NULL,
    @������������� NVARCHAR(256) = NULL,
    @���������� NVARCHAR(256) = '',
    @��������������� NVARCHAR(128) = '',
    @���������� NVARCHAR(512) = '',
    @������ NVARCHAR(512) = '',
    @������� NVARCHAR(64) = '',
    @���������� FLOAT,
    @����������� NVARCHAR(16),
    @�������������� NVARCHAR(32) = '�����'
AS
BEGIN
    DECLARE @�������������� INT;
	DECLARE @������������������ INT;

    SELECT @�������������� = ��������������
    FROM ����������������������
    WHERE ��������������������� = @�����������;

    IF @�������������� IS NULL
    BEGIN
        RAISERROR('������� ��������� �� �������', 16, 1);
        RETURN;
    END

	SELECT @������������������ = ������������������
    FROM �����������������������
    WHERE �������������� = @��������������;

    IF @�������������� IS NULL
    BEGIN
        RAISERROR('������ �������� �� ������', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    INSERT INTO �������� (
        ����������������, CAS, �������������, ����������,
        ���������������, ����������, ������, �������
    )
    VALUES (
        @����������������, @CAS, @�������������, @����������,
        @���������������, @����������, @������, @�������
    );

    DECLARE @����������� INT = SCOPE_IDENTITY();

    INSERT INTO ����������������� (
        �����������, ����������, ��������������, ������������������
    )
    VALUES (
        @�����������, @����������, @��������������, @������������������
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
	SELECT �.[����������������]
		   ,�.[CAS]
           ,�.[�������������]
		   ,��.[����������]
		   ,���.[���������������������]
		   ,���.[��������������]
           ,�.[����������]
           ,�.[���������������]
           ,�.[����������]
           ,�.[�������]
	FROM �������� AS �
	INNER JOIN ����������������� AS ��
		ON �.����������� = ��.�����������
	INNER JOIN ���������������������� AS ���
		ON ��.�������������� = ���.��������������
	INNER JOIN ����������������������� AS ���
		ON ��.������������������ = ���.������������������  
	WHERE �.����������� = @Param1
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE ProcUpdateField
    @ID INT,
    @������� NVARCHAR(128),
    @������������� NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    -- �������� �� ������������� ����
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = '��������' AND COLUMN_NAME = @�������
    )
    BEGIN
        RAISERROR('���� %s �� ���������� � ������� ��������.', 16, 1, @�������)
        RETURN
    END

    -- ������ ������ � ��������� ���
    DECLARE @Sql NVARCHAR(MAX)
    SET @Sql = '
        UPDATE ��������
        SET [' + @������� + '] = @�������������
        WHERE ����������� = @ID
    '

    EXEC sp_executesql @Sql,
        N'@ID INT, @������������� NVARCHAR(512)',
        @ID = @ID, @������������� = @�������������
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE ProcUpdateFieldU
    @ID INT,
    @������� NVARCHAR(128),
    @������������� NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    -- �������� �� ������������� ����
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = '������������' AND COLUMN_NAME = @�������
    )
    BEGIN
        RAISERROR('���� %s �� ���������� � ������� ������������.', 16, 1, @�������)
        RETURN
    END

    -- ������ ������ � ��������� ���
    DECLARE @Sql NVARCHAR(MAX)
    SET @Sql = '
        UPDATE ������������
        SET [' + @������� + '] = @�������������
        WHERE ��������������� = @ID
    '

    EXEC sp_executesql @Sql,
        N'@ID INT, @������������� NVARCHAR(512)',
        @ID = @ID, @������������� = @�������������
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

    SELECT TOP 1 ���������������
    FROM ������������
    WHERE ��� = @Login
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE LogChange
    @��������������� INT,
    @���������� NVARCHAR(32),
    @����������� NVARCHAR(16),
    @������������� NVARCHAR(32),
    @������ NVARCHAR(32),
    @��������� NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ��������������� (
        ���������������,
        �������������,
        ����������,
        �����������,
        �������������,
        ������,
        ���������
    )
    VALUES (
        @���������������,
        GETDATE(),
        @����������,
        @�����������,
        @�������������,
        @������,
        @���������
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
	SELECT �.[����������������]
		   ,�.[CAS]
		   ,'' AS ����������
	FROM �������� AS �
	INNER JOIN ����������������� AS ��
		ON �.����������� = ��.�����������
	WHERE ��.[����������] = 0 OR ��.������������������ = 1
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
	SELECT ���
		   ,�������
		   ,������
		   ,������
	FROM ������������
END
GO

-- ===============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ===============================================
CREATE OR ALTER PROCEDURE CorrectUserInformation_1
	-- Add the parameters for the stored procedure here
	@���� NVARCHAR(32)
AS
BEGIN
	SELECT ���������������
		   ,���
		   ,�������
		   ,������
		   ,������
	FROM ������������  
	WHERE ��� LIKE @���� + N'%' OR ������� LIKE @���� + N'%'
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
	SELECT ���
		   ,�������
		   ,������
		   ,������
	FROM ������������
	WHERE ��� LIKE @Param1 + N'%' OR ������� LIKE @Param1 + N'%'
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
	SELECT ��.ID
		   ,�.������� AS '���_���_���������'
		   ,��.�������������
		   ,��.�����������
		   ,��.����������
		   ,��.�������������
		   ,��.������
		   ,��.���������
	FROM ��������������� AS ��
	INNER JOIN ������������ AS �
		ON ��.��������������� = �.���������������
END