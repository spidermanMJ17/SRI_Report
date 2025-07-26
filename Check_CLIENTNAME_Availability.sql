
-- Stored Procedure: Check_CLIENTNAME_Availability

USE [CRM]
GO

ALTER PROCEDURE [dbo].[Check_CLIENTNAME_Availability] 
    @p_client_name AS varchar(100),
    @p_user_id AS int,
    @p_result AS int output
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AdGroup AS int;
    SELECT @AdGroup = group_id FROM m_user WHERE user_id = @p_user_id;

    IF (@AdGroup = 0)
    BEGIN
        SELECT 
            cl.id AS ClientID,
            cl.n_clientName,
            CONVERT(varchar(11), dbo.[fn_ClientInitiationDate](n_client_id, client_status, client_sales_status), 106) AS ClientName,
            (SELECT first_name FROM m_user WHERE user_id = cl.n_primary_dealer) AS PrimaryDealer,
            (SELECT status_name FROM t_client_status WHERE id = cl.client_status) AS ClientSalesStatus,
            CASE 
                WHEN cl.client_status = 'Prospect' THEN 'Leads' 
                ELSE 'Client' 
            END AS ClientType,
            (SELECT group_name FROM m_group WHERE group_id = cl.group_id) AS ClientGroupName,
            CASE 
                WHEN cl.client_sales_status IN (3, 9, 13) THEN 
                    CASE 
                        WHEN DATEDIFF(dd, cd.n_end_date, GETDATE()) > 90 THEN 1 
                        ELSE 0 
                    END 
                ELSE 0 
            END AS NumOfYears
        FROM m_clients AS cl
        JOIN (
            SELECT * FROM n_client_dealer_details WHERE n_end_date IS NULL
        ) AS cd ON cl.ID = cd.n_client_id
        WHERE 
            cl.n_clientName LIKE '%' + @p_client_name + '%'
            OR REPLACE(cl.n_clientName, ' ', '') LIKE '%' + REPLACE(@p_client_name, ' ', '') + '%'
        ORDER BY cl.n_clientName;
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT * FROM m_clients WHERE n_clientName = @p_client_name)
        BEGIN
            SET @p_result = 0;
        END
        ELSE
        BEGIN
            SET @p_result = 1;
        END
    END
END
