<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="roxic" uri="http://java.sun.com/jsp/jstl/core" %>
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

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <script type="text/javascript">
        $(function () {

            $(".time").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });

            var json = {
                <%
                    for(String key:set){

                        String value = possibilityMap.get(key);
                %>

                "<%=key%>" : <%=value%>,

                <%
                    }
                %>
            };

            $("#edit-stage").change(function () {
                //取得选中的阶段
                var stage = $("#edit-stage").val();

                var possibility = json[stage];
                //alert(possibility);

                //为可能性的文本框赋值
                $("#edit-possibility").val(possibility+"%");
            })

//放大镜图标按钮绑定事件
            $("#openSearchModalBtn1").click(function () {

                getActivityListByName();

                $("#findMarketActivity").modal("show");
            })

            $("#openSearchModalBtn2").click(function () {

                //getActivityListByName();
                getContactsListByName();

                $("#findContacts").modal("show");
            })

            //给动态模糊绑定键盘事件
            $("#activityName").keydown(function (event) {
                if(event.keyCode==13){

                    getActivityListByName();
                    return false;

                }

            })

//--------------------------------------------------------------------
            $("#contactsName").keydown(function (event) {
                if(event.keyCode==13){

                    //getActivityListByName();
                    getContactsListByName();
                    return false;

                }

            })

            //为提交活动源按钮绑定事件
            $("#submitActivityBtn").click(function () {
                var $xz = $("input[name=xz]:checked");
                var activityId = $xz.val();

                var name = $("#"+activityId).html();
                $("#activity").val(name);
                $("#activityId").val(activityId);

                $("#findMarketActivity").modal("hide");

            })
//--------------------------------------------------------------------
            $("#submitContactsBtn").click(function () {
                var $xz2 = $("input[name=xz2]:checked");
                var contactsId = $xz2.val();

                var name = $("#"+contactsId).html();
                $("#contacts").val(name);
                $("#contactsId").val(contactsId);

                $("#findContacts").modal("hide");

            })

            $("#updateBtn").click(function () {
                //提交表单
                $("#tranForm").submit();
            })

        });//load事件末尾

        function getActivityListByName() {
            $.ajax({
                url:"workbench/clue/getActivityListByName.do",
                data:{
                    "activityName":$.trim($("#activityName").val())
                },
                type:"get",
                dataType:"json",
                success: function (data) {
                    var html = "";
                    $.each(data,function (i,n) {
                        html += '<tr>';
                        html += '<td><input type="radio" name="xz" value="'+n.id+'"/></td>';
                        html += '<td id="'+n.id+'">'+n.name+'</td>';
                        html += '<td>'+n.startDate+'</td>';
                        html += '<td>'+n.endDate+'</td>';
                        html += '<td>'+n.owner+'</td>';
                        html += '</tr>';
                    })

                    $("#activitySearchBody").html(html);
                }
            })
        }

        function getContactsListByName() {

            $.ajax({
                url:"workbench/transaction/getContactsListByName.do",
                data:{
                    "contactsName":$.trim($("#contactsName").val()),
                    "company":$.trim($("#edit-customerName").val())
                },
                type:"get",
                dataType:"json",
                success: function (data) {
                    var html = "";
                    $.each(data,function (i,n) {
                        html += '<tr>';
                        html += '<td><input type="radio" name="xz2" value="'+n.id+'"/></td>';
                        html += '<td id="'+n.id+'">'+n.fullname+n.appellation+'</td>';
                        html += '<td>'+n.email+'</td>';
                        html += '<td>'+n.mphone+'</td>';
                        html += '</tr>';
                    })


                    $("#contactsSearchBody").html(html);
                }
            })

        }

    </script>

</head>
<body>

<!-- 查找市场活动 -->
<div class="modal fade" id="findMarketActivity" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询" id="activityName">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable4" class="table table-hover"
                       style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody id="activitySearchBody">
                    <%--<tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>--%>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="submitActivityBtn">确定</button>
            </div>
        </div>
    </div>
</div>

<!-- 查找联系人 -->
<div class="modal fade" id="findContacts" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找联系人</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询" id="contactsName">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>邮箱</td>
                        <td>手机</td>
                    </tr>
                    </thead>
                    <tbody id="contactsSearchBody">
                    <%--<tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>李四</td>
                        <td>lisi@bjpowernode.com</td>
                        <td>12345678901</td>
                    </tr>
                    <tr>
                        <td><input type="radio" name="activity"/></td>
                        <td>李四</td>
                        <td>lisi@bjpowernode.com</td>
                        <td>12345678901</td>
                    </tr>--%>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="submitContactsBtn">确定</button>
            </div>
        </div>
    </div>
</div>


<div style="position:  relative; left: 30px;">
    <h3>更新交易</h3>
    <div style="position: relative; top: -40px; left: 70%;">
        <button type="button" class="btn btn-primary" id="updateBtn">更新</button>
        <button type="button" class="btn btn-default" onclick="window.history.back()">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">
</div>
<form action="workbench/transaction/update.do" id="tranForm" method="post" class="form-horizontal" role="form" style="position: relative; top: -30px;">
    <input type="hidden" name="id" value="${tran.id}">
    <div class="form-group">
        <label for="edit-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control"  value="${tran.owner}" readonly>
            <input type="hidden"  name="owner" value="${tran.d}"/>
        </div>
        <label for="edit-amountOfMoney" class="col-sm-2 control-label">金额</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="money" value="${tran.money}">
        </div>
    </div>

    <div class="form-group">
        <label for="edit-transactionName" class="col-sm-2 control-label">名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" name="name" value="${tran.name}">
        </div>
        <label for="edit-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control time" name="expectedDate" value="${tran.expectedDate}" readonly>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-accountName" class="col-sm-2 control-label">客户名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control"  id="edit-customerName" value="${tran.customerId}"  readonly>
            <input type="hidden" name="customerId" value="${tran.c}">
        </div>
        <label for="edit-transactionStage" class="col-sm-2 control-label">阶段<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" name="stage" value="${tran.stage}" >
                <roxic:forEach items="${stage}" var="s">
                    <option value="${s.value}">${s.text}</option>
                </roxic:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-transactionType" class="col-sm-2 control-label">类型</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" name="type"  value="${tran.type}">
                <roxic:forEach items="${transactionType}" var="t">
                    <option value="${t.value}">${t.text}</option>
                </roxic:forEach>
            </select>
        </div>
        <label for="create-possibility" class="col-sm-2 control-label">可能性</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-possibility" readonly>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-clueSource" class="col-sm-2 control-label">来源</label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" name="source"  value="${tran.source}">
                <roxic:forEach items="${source}" var="sour">
                    <option value="${sour.value}">${sour.text}</option>
                </roxic:forEach>
            </select>
        </div>
        <label for="edit-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);"
                                                                                         id="openSearchModalBtn1"><span
                class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="activity" value="${tran.activityId}" readonly>
            <input type="hidden" id="activityId" name="activityId" value="${tran.a}"/>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);"
                                                                                          id="openSearchModalBtn2"><span
                class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="contacts" value="${tran.contactsId}" readonly>
            <input type="hidden" id="contactsId" name="contactsId" value="${tran.b}"/>
        </div>
    </div>

    <div class="form-group">
        <label for="create-describe" class="col-sm-2 control-label">描述</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" name="description" >${tran.description}</textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" name="contactSummary">${tran.contactSummary}</textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control time" name="nextContactTime" readonly value="${tran.nextContactTime}">
        </div>
    </div>

</form>
</body>
</html>