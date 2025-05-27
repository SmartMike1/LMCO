-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE GetUserIdBySurname
    @Фамилия NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 КодПользователя
    FROM Пользователи
    WHERE Фамилия = @Фамилия
END