USE [wms_rfid_db]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
ALTER PROCEDURE [dbo].[pro_get_new_task_for_small_stock_out] 
	@srm_name  nvarchar(50),
	@travelPos int,
	@waitingTask int,
	@waitingTasks nvarchar(4000),
	@product_code nvarchar(20)
AS
	declare @empty_position_id int
	
	declare @empty_position cursor
BEGIN	
	SET NOCOUNT ON;
	
	set @empty_position = cursor for
		select top 1 id from wcs_position
		where position_type = '03'    /*СƷ�ֳ���λ��*/
			and has_goods = 0
			and srmName = @srm_name   /*��ǰλ��Ϊ��ǰ�Ѷ��ִ��*/
	
	open @empty_position
	fetch next from @empty_position into @empty_position_id
	if(@@fetch_status=0)
	begin
		select top 1 a.*,
			f.length,f.width,f.height,
			
			c.travel_pos as travelPos1,c.lift_pos as liftPos1,/*��ǰλ��*/
			d.travel_pos as travelPos2,d.lift_pos as liftPos2,/*�¸�λ��*/
			
			c.id as currentPositionID,                        --��ǰλ��
			c.position_name as currentPositionName,
			c.position_type as currentPositionType,
			c.extension as CurrentPositionExtension,
			a.current_position_state as currentPositionState,
			c.has_get_request,
			
			d.id as nextPositionID,							  --�¸�λ��					
			d.position_name as nextPositionName,
			d.position_type as nextPositionType,
			d.extension as nextPositionExtension,
			d.has_put_request,
			
			e.id as endPositionID,							  --Ŀ��λ��	
			e.position_name as endPositionName,
			e.position_type as endPositionType     
		from wcs_task a
			left join wcs_position b on b.id = a.origin_position_id   --��ʼλ��
			left join wcs_position c on c.id = a.current_position_id  --��ǰλ��
			left join wcs_position d on d.id = @empty_position_id	  --�¸�λ��
			left join wcs_position e on e.id = a.target_position_id   --Ŀ��λ��
			left join wcs_product_size	f on f.product_code = a.product_code
		where a.[state] = '01'			 			/*����ȴ���*/
			and e.position_type != '03'				/*��ǰλ�ò���СƷ�ֳ���λ��*/
			and a.current_position_state = '02'		/*�ѵ��ﵱǰλ��*/
			and c.able_stock_out = 1				/*��ǰλ�ÿ��Գ���*/
			and c.srmName = @srm_name				/*��ǰλ��Ϊ��ǰ�Ѷ��ִ��*/
			and d.srmName = @srm_name				/*�¸�λ��Ϊ��ǰ�Ѷ��ִ��*/
			and e.position_type = '03'				/*Ŀ��λ����СƷ�ֳ���λ��*/
	end
	close @empty_position
	deallocate @empty_position	
END