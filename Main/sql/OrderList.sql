
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