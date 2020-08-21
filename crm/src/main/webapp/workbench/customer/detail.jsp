<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="roxic" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
	Map<String,String> possibilityMap = (Map<String,String>)application.getAttribute("possibilityMap");
	Set<String> set = possibilityMap.keySet();
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet"/>


<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$(".time").datetimepicker({
			minView: "month",
			language: 'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		//为修改按钮绑定点击事件,打开修改窗口的模态窗口
		$("#editBtn").click(function () {

			$(".time").datetimepicker({
				minView: "month",
				language: 'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			var id = "${customer.id}";
			$.ajax({
				url: "workbench/customer/getUserListAndCustomer.do",
				data: {
					"id": id
				},
				type: "get",
				dataType: "json",
				success: function (data) {
					/*
                    * data
                    *       用户列表
                    *       市场活动对象
                    *
                    *       {"uList":[{用户1},{用户2},{用户3}...],"activity":{活动}}
                    * */

					//所有者下拉框
					var html = "<option></option>";
					$.each(data.uList, function (i, n) {
						html += "<option value='" + n.id + "'>" + n.name + "</option>>"
					})

					$("#edit-owner").html(html);

					//处理其他内容
					$("#edit-id").val(data.customer.id);
					$("#edit-owner").val(data.customer.owner);
					$("#edit-name").val(data.customer.name);
					$("#edit-phone").val(data.customer.phone);
					$("#edit-website").val(data.customer.website);
					$("#edit-description").val(data.customer.description);
					$("#edit-contactSummary2").val(data.customer.contactSummary);
					$("#edit-nextContactTime2").val(data.customer.nextContactTime);
					$("#edit-address").val(data.customer.address);

					//所有值填进去后，打开模态窗口
					$("#editCustomerModal").modal("show");

				}
			})
		})

		//为更新按钮绑定事件
		/*
        * 在开发中，先做添加，再做修改
        * 所以为了节省开发时间，修改操作一般复制添加操作
        * */
		$("#updateBtn").click(function () {

			$.ajax({
				url: "workbench/customer/update.do",
				data: {

					"id": $.trim($("#edit-id").val()),
					"owner": $.trim($("#edit-owner").val()),
					"name": $.trim($("#edit-name").val()),
					"phone": $.trim($("#edit-phone").val()),
					"website": $.trim($("#edit-website").val()),
					"description": $.trim($("#edit-description").val()),
					"contactSummary": $.trim($("#edit-contactSummary2").val()),
					"nextContactTime": $.trim($("#edit-nextContactTime2").val()),
					"address": $.trim($("#edit-address").val())


				},
				type: "post",
				dataType: "json",
				success: function (data) {
					if (data.success) {

						window.location.href = "workbench/customer/detail.do?id=" + "${customer.id}";
						$("#editCustomerModal").modal("hide");

					} else {
						alert("修改客户信息失败！");
					}
				}
			})
		})


		//页面加载完毕后,展现市场活动关联的备注信息列表
		showRemarkList();

		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})

		//给备注保存按钮添加事件
		$("#saveRemarkBtn").click(function () {
			$.ajax({
				url:"workbench/customer/saveRemark.do",
				data:{
					"noteContent" : $.trim($("#remark").val()),
					"customerId" : "${customer.id}"
				},
				type:"post",
				dataType:"json",
				success: function (data) {
					/*
                    * data
                    *       {"success":true/false,"cur":{备注}}
                    * */
					if(data.success){

						//清空文本域
						$("#remark").val("");

						//添加成功，在文本域上放加个div
						var html = "";

						html += '<div id="'+data.cur.id+'" class="remarkDiv" style="height: 60px;">';
						html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
						html += '<div style="position: relative; top: -40px; left: 40px;">';
						html += '<h5>'+data.cur.noteContent+'</h5>';
						html += '<font color="gray">客户</font> <font color="gray">-</font> <b>${customer.name}</b>';
						html += '<small style="color: gray;"> '+data.cur.createTime+' 由'+data.cur.createBy+'</small>';
						html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html += '<a class="myHref" href="javascript:void(0);" "><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #0000FF;"></span></a>';
						html += ' &nbsp;&nbsp;&nbsp;&nbsp;';
						html += '<a class="myHref" href="javascript:void(0);" onclick="removeRemark(\''+data.cur.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
						html += '</div>';
						html += '</div>';
						html += '</div>';

						$("#remarkDiv").before(html);

					}else {
						alert("添加备注失败！")
					}
				}
			})
		})

		//为更新按钮绑定事件
		$("#updateRemarkBtn").click(function () {

			var id = $("#remarkId").val();
			$.ajax({
				url:"workbench/customer/updateRemark.do",
				data:{

					"id": id ,
					"noteContent": $.trim($("#noteContent").val())

				},
				type:"post",
				dataType:"json",
				success: function (data) {

					/*
                    * data
                    *       {"sueccess":true/false,"cur":{备注对象}}
                    * */
					if(data.success){

						//更新div相应的信息，noteContent,editTime,editBy
						$("#e" + id).html(data.cur.noteContent);
						$("#roxic" + id).html(data.cur.editTime +' 由'+ data.cur.editBy);
						//更新内容之后，关闭模态窗口
						$("#editRemarkModal").modal("hide");
					} else {
						alert("备注修改失败！");
					}

				}
			})
		})

		//为删除按钮绑定事件，执行市场活动的删除操作
		$("#deleteBtn").click(function () {


			//增加个确认框
			if (confirm("确定删除该客户吗?")) {


				//alert(param);

				var id = "${customer.id}";
				$.ajax({
					url: "workbench/customer/delete.do",
					data: {
						"id": id
					},
					type: "post",
					dataType: "json",
					success: function (data) {
						/*data
                        *       {"success":true/false}
                        * */
						if (data.success) {

							//删除成功后
							window.location.href = "workbench/customer/index.jsp";


						} else {
							alert("删除失败！")
						}
					}
				})

			}



		})

		showTranList();

		$("#removeTranBtn").click(function () {
			$.ajax({
				url:"workbench/transaction/remove.do",
				data:{
					"tranId":"${tran.id}"
				},
				type:"",
				dataType:"json",
				success: function (data) {

				}
			})
		})

		showContactsList();

		$("#addContactsBtn").click(function () {
				//alert(123);
				$.ajax({
					url:"workbench/customer/getUserList.do",
					type:"get",
					dataType:"json",
					success: function (data) {
						var html = "<option></option>";
						$.each(data,function(i,n){
							html += "<option value='"+n.id+"'>"+n.name+"</option>";
						})

						$("#create-owner").html(html);
						$("#create-customerId").val("${customer.id}");

						var id = "${user.id}"
						$("#create-owner").val(id);

						$("#createContactsModal").modal("show");
					}
				})
		})

		$("#saveContactsBtn").click(function () {
			$.ajax({
				url:"workbench/customer/saveContacts.do",
				data:{
					"fullname":$.trim($("#create-fullname").val()),
					"appellation":$.trim($("#create-appellation").val()),
					"customerId":$.trim($("#create-customerId").val()),
					"owner":$.trim($("#create-owner").val()),
					"source":$.trim($("#create-source").val()),
					"job":$.trim($("#create-job").val()),
					"mphone":$.trim($("#create-mphone").val()),
					"nextContactTime":$.trim($("#create-nextContactTime").val()),
					"address":$.trim($("#create-address").val()),
					"email":$.trim($("#create-email").val()),
					"birth":$.trim($("#create-birth").val()),
					"description":$.trim($("#create-description").val()),
					"contactSummary":$.trim($("#create-contactSummary").val())
				},
				type:"post",
				dataType:"json",
				success: function (data) {
					if(data.success){
						$("#createContactsModal").modal("hide");
						showContactsList();
					}else {
						alert("添加联系人失败！");
					}

				}
			})
		})



	});//load事件末尾

	function removeContacts(id) {
		if(confirm("请确认删除该联系人！")){
			$.ajax({
				url:"workbench/contacts/delete.do",
				data:{
					"id":id
				},
				type:"get",
				dataType:"json",
				success: function (data) {
					if(data.success){
						showContactsList();
					}else {
						alert("联系人删除失败！")
					}
				}
			})
		}

	}

	function showContactsList() {
		$.ajax({
			url:"workbench/customer/getContactsListByCuid.do",
			data:{
				"customerId":"${customer.id}"
			},
			type:"get",
			dataType:"json",
			success: function (data) {
				var html = "";
				$.each(data,function (i,n) {
				    html += '<tr>';
					html += '<td><a href="workbench/transaction/detail.do?id='+n.id+' style="text-decoration: none;">'+n.fullname+' '+n.appellation+'</a></td>';
					html += '<td>'+n.email+'</td>';
					html += '<td>'+n.mphone+'</td>';
					html += '<td><a href="javascript:void(0);" onclick="removeContacts(\''+n.id+'\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				})

				$("#contactsBody").html(html);
			}
		})
	}

	function removeTran(id) {
		if(confirm("请确认删除该交易！")){
			$.ajax({
				url:"workbench/transaction/remove.do",
				data:{
					"tranId":id
				},
				type:"get",
				dataType:"json",
				success: function (data) {
					if (data.success) {
						showTranList();
					} else {
						alert("删除失败！")
					}
				}
			})
		}
	}

	function showTranList() {
		$.ajax({
			url:"workbench/customer/getTranListByCuid.do",
			data:{
				"customerId":"${customer.id}"
			},
			type:"get",
			dataType:"json",
			success: function (data) {
				var html = "";
				$.each(data,function (i,n) {
					html += '<tr>';
					html += '<td><a href=workbench/transaction/detail.do?id=' + n.id + ' style="text-decoration: none;">'+n.name+'</a></td>';
					html += '<td>'+n.money+'</td>';
					html += '<td>'+n.stage+'</td>';
					html += '<td>'+n.expectedDate+'</td>';
					html += '<td>'+n.type+'</td>';
					html += '<td><a href="javascript:void(0);" onclick="removeTran(\''+n.id+'\')" style="text-decoration: none;" id="'+n.id+'"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				})

				$("#tranBody").html(html);
			}
		})
	}

	function showRemarkList() {

		$.ajax({
			url:"workbench/customer/getRemarkListByCuid.do",
			data:{
				"customerId":"${customer.id}"
			},
			type:"get",
			dataType:"json",
			success: function (data) {

				/*
                * data
                *       [{备注1},{备注2},{备注3},{备注4}...]
                * */
				var html = "";

				$.each(data,function (i,n) {

					html += '<div id="'+n.id+'" class="remarkDiv" style="height: 60px;">';
					html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html += '<div style="position: relative; top: -40px; left: 40px;">';
					html += '<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
					html += '<font color="gray">客户</font> <font color="gray">-</font> <b>${customer.name}</b>';
					html += '<small style="color: gray;" id="roxic'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #0000FF;"></span></a>';
					html += ' &nbsp;&nbsp;&nbsp;&nbsp;';
					html += '<a class="myHref" href="javascript:void(0);" onclick="removeRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '</div>';
					html += '</div>';
					html += '</div>';

				})

				$("#remarkDiv").before(html);

			}
		})

	}

	function removeRemark(id) {
		$.ajax({
			url:"workbench/customer/removeRemark.do",
			data:{

				"id":id
			},
			type:"post",
			dataType:"json",
			success: function (data) {

				/*
                * data:{"success":true/false}
                * */
				if(data.success){
					//以下方法不行，使用的是before，会追加
					//showRemarkList();

					//找到需要删除的div
					$("#" + id).remove();
				}else {
					alert("删除备注失败！")
				}
			}
		})
	}

	function editRemark(id){
		//alert(id);
		//将模态窗口中的隐藏域中的id赋值
		$("#remarkId").val(id);
		var noteContent = $("#e"+id).html();
		$("#editRemarkModal").modal("show");
		$("#noteContent").val(noteContent);
	}
	
</script>

</head>
<body>

	<!-- 删除联系人的模态窗口 -->
	<div class="modal fade" id="removeContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除联系人</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该联系人吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-danger" data-dismiss="modal">删除</button>
				</div>
			</div>
		</div>
	</div>



	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">

						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
									<roxic:forEach items="${source}" var="roxic2">
										<option value="${roxic2.value}">${roxic2.text}</option>
									</roxic:forEach>
								</select>
							</div>
						</div>

						<div class="form-group">
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
									<roxic:forEach items="${appellation}" var="roxic1">
										<option value="${roxic1.value}">${roxic1.text}</option>
									</roxic:forEach>
								</select>
							</div>

						</div>

						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>

						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-birth" readonly>
							</div>
						</div>

						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" value="${customer.name}" readonly>
								<input type="hidden" id="create-customerId" >
							</div>
						</div>

						<div class="form-group" style="position: relative;">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>

						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="create-nextContactTime" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveContactsBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
    <div class="modal fade" id="editCustomerModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改客户</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id">
                        <div class="form-group">
                            <label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-owner">

                                </select>
                            </div>
                            <label for="edit-customerName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name" >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website">
                            </div>
                            <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-phone" >
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-description"></textarea>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary2"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime2" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="edit-nextContactTime2" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
                            </div>
                        </div>
                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 修改客户备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="edit-describe2" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>



	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.location.href='workbench/customer/index.jsp';"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${customer.name} <small><a href="javascript:void(0);" >${customer.website}</a></small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${customer.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${customer.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${customer.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${customer.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${customer.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">&nbsp;${customer.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${customer.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">&nbsp;${customer.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					&nbsp;${customer.contactSummary}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${customer.nextContactTime}</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${customer.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					&nbsp;${customer.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 10px; left: 40px;" id="remarkBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		

		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tranBody">
						<%--<tr>
							<td><a href="transaction/detail.html" style="text-decoration: none;">动力节点-交易01</a></td>
							<td>5,000</td>
							<td>谈判/复审</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>新业务</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeTransactionModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" onclick="window.location.href='workbench/transaction/add.do?name=${customer.name}';" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="contactsBody">
						<%--<tr>
							<td><a href="contacts/detail.html" style="text-decoration: none;">李四</a></td>
							<td>lisi@bjpowernode.com</td>
							<td>13543645364</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="addContactsBtn" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>
		</div>
	</div>
	
	<div style="height: 200px;"></div>
</body>
</html>