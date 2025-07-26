
-- Optimized Stored Procedure with Inline Comments
USE [CRM]
GO

ALTER PROCEDURE [dbo].[Check_CLIENTNAME_Availability] 
    @p_client_name AS varchar(100),
    @p_user_id AS int,
    @p_result AS int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;  -- ✅ Same as original: suppresses extra result sets for cleaner output.

    DECLARE @AdGroup INT;
    SELECT @AdGroup = group_id FROM m_user WHERE user_id = @p_user_id;  -- ✅ Same as original.

    IF @AdGroup = 0  -- ✅ Admin user logic remains the same.
    BEGIN
        SELECT 
            cl.id AS ClientID,
            cl.n_clientName,
            CONVERT(varchar(11), dbo.fn_ClientInitiationDate(cl.n_client_id, cl.client_status, cl.client_sales_status), 106) AS ClientName,

            -- ✅ REPLACED subquery with JOIN: better performance & readability.
            mu.first_name AS PrimaryDealer,

            -- ✅ REPLACED subquery with JOIN: faster lookup for status name.
            cs.status_name AS ClientSalesStatus,

            CASE 
                WHEN cl.client_status = 'Prospect' THEN 'Leads' 
                ELSE 'Client' 
            END AS ClientType,

            -- ✅ REPLACED subquery with JOIN: improves clarity and join optimization.
            mg.group_name AS ClientGroupName,

            -- ✅ Merged condition into single CASE: more efficient.
            CASE 
                WHEN cl.client_sales_status IN (3, 9, 13) AND DATEDIFF(DAY, cd.n_end_date, GETDATE()) > 90 THEN 1
                ELSE 0 
            END AS NumOfYears

        FROM m_clients cl

        -- ✅ ADDED INNER JOIN instead of correlated subquery: avoids scanning entire table multiple times.
        INNER JOIN n_client_dealer_details cd ON cl.ID = cd.n_client_id AND cd.n_end_date IS NULL

        -- ✅ NEW: LEFT JOIN to pull dealer, status, and group info in a single pass.
        LEFT JOIN m_user mu ON mu.user_id = cl.n_primary_dealer
        LEFT JOIN t_client_status cs ON cs.id = cl.client_status
        LEFT JOIN m_group mg ON mg.group_id = cl.group_id

        -- ✅ Using flexible matching + REPLACE for space-insensitive name search.
        WHERE 
            cl.n_clientName LIKE '%' + @p_client_name + '%'
            OR REPLACE(cl.n_clientName, ' ', '') LIKE '%' + REPLACE(@p_client_name, ' ', '') + '%'

        ORDER BY cl.n_clientName;
    END
    ELSE
    BEGIN
        -- ✅ No change, but simplified EXISTS clause with SELECT 1 instead of *.
        IF EXISTS (
            SELECT 1 
            FROM m_clients 
            WHERE n_clientName = @p_client_name
        )
            SET @p_result = 0;  -- Client exists.
        ELSE
            SET @p_result = 1;  -- Client available.
    END
END
