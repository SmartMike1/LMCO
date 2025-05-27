
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