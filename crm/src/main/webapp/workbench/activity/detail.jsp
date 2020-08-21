<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
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

    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>


    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            $(".remarkDiv").mouseover(function () {
                $(this).children("div").children("div").show();
            });

            $(".remarkDiv").mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            $(".myHref").mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            $(".myHref").mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
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

                var id = "${activity.id}";
                $.ajax({
                    url: "workbench/activity/getUserListAndActivity.do",
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

                        $("#edit-marketActivityOwner").html(html);

                        //处理其他内容
                        $("#edit-marketActivityName").val(data.activity.name);
                        $("#edit-marketActivityOwner").val(data.activity.owner);
                        $("#edit-startTime").val(data.activity.startDate);
                        $("#edit-endTime").val(data.activity.endDate);
                        $("#edit-cost").val(data.activity.cost);
                        $("#edit-describe").val(data.activity.description);
                        $("#edit-id").val(data.activity.id);

                        //所有值填进去后，打开模态窗口
                        $("#editActivityModal").modal("show");

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
                    url: "workbench/activity/update.do",
                    data: {

                        "id": $.trim($("#edit-id").val()),
                        "owner": $.trim($("#edit-marketActivityOwner").val()),
                        "name": $.trim($("#edit-marketActivityName").val()),
                        "startDate": $.trim($("#edit-startTime").val()),
                        "endDate": $.trim($("#edit-endTime").val()),
                        "cost": $.trim($("#edit-cost").val()),
                        "description": $.trim($("#edit-describe").val())

                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.success) {

                            window.location.href = "workbench/activity/detail.do?id=" + "${activity.id}";
                            $("#editActivityModal").modal("hide");

                        } else {
                            alert("修改市场活动失败！");
                        }
                    }
                })
            })

            //为删除按钮绑定事件，执行市场活动的删除操作
            $("#deleteBtn").click(function () {


                //增加个确认框
                if (confirm("确定删除该市场活动吗?")) {


                    //alert(param);

                    var id = "${activity.id}";
                    $.ajax({
                        url: "workbench/activity/delete.do",
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
                                window.location.href = "workbench/activity/index.jsp";


                            } else {
                                alert("删除失败！")
                            }
                        }
                    })

                }


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
                    url:"workbench/activity/saveRemark.do",
                    data:{
                        "noteContent" : $.trim($("#remark").val()),
                        "activityId" : "${activity.id}"
                    },
                    type:"post",
                    dataType:"json",
                    success: function (data) {
                        /*
                        * data
                        *       {"success":true/false,"ar":{备注}}
                        * */
                        if(data.success){

                            //清空文本域
                            $("#remark").val("");

                            //添加成功，在文本域上放加个div
                            var html = "";

                            html += '<div id="'+data.ar.id+'" class="remarkDiv" style="height: 60px;">';
                            html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                            html += '<div style="position: relative; top: -40px; left: 40px;">';
                            html += '<h5>'+data.ar.noteContent+'</h5>';
                            html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b>';
                            html += '<small style="color: gray;"> '+data.ar.createTime+' 由'+data.ar.createBy+'</small>';
                            html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                            html += '<a class="myHref" href="javascript:void(0);" "><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #0000FF;"></span></a>';
                            html += ' &nbsp;&nbsp;&nbsp;&nbsp;';
                            html += '<a class="myHref" href="javascript:void(0);" onclick="removeRemark(\''+data.ar.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
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
                    url:"workbench/activity/updateRemark.do",
                    data:{

                        "id": id ,
                        "noteContent": $.trim($("#noteContent").val())

                    },
                    type:"post",
                    dataType:"json",
                    success: function (data) {

                        /*
                        * data
                        *       {"sueccess":true/false,"ar":{备注对象}}
                        * */
                       if(data.success){

                           //更新div相应的信息，noteContent,editTime,editBy
                           $("#e" + id).html(data.ar.noteContent);
                           $("#roxic" + id).html(data.ar.editTime +' 由'+ data.ar.editBy);
                           //更新内容之后，关闭模态窗口
                           $("#editRemarkModal").modal("hide");
                       } else {
                           alert("备注修改失败！");
                       }

                    }
                })
            })


        });//load事件结尾

        function showRemarkList() {

            $.ajax({
                url:"workbench/activity/getRemarkListByAid.do",
                data:{
                    "activityId":"${activity.id}"
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
                            html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activity.name}</b>';
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
                url:"workbench/activity/removeRemark.do",
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

<!-- 修改市场活动备注的模态窗口 -->
<div class="modal fade" id="editRemarkModal" role="dialog">
    <%-- 备注的id --%>
    <input type="hidden" id="remarkId">
    <div class="modal-dialog" role="document" style="width: 40%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">修改备注</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">内容</label>
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

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">

                    <input type="hidden" id="edit-id"/>
                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">

                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="edit-startTime" readonly>
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="edit-endTime" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <%--

                            关于textarea：
                                        1. 一定要以标签对的形式呈现，正常状态下标签对要紧挨着。
                                        2. textarea虽然以标签对的形式来呈现，但是它也是属于表单元素范畴，所有对textarea的取值和复制操作，统一用val()方法

                            --%>
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
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

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.location.href='workbench/activity/index.jsp';"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>市场活动-${activity.name}
            <small>${activity.startDate} ~ ${activity.endDate}</small>
        </h3>
    </div>
    <div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除
        </button>
    </div>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;" id="detail-owner">
            <b>&nbsp;${activity.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;" id="detail-name"><b>${activity.name}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>

    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">开始日期</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;" id="detail-startDate">
            <b>&nbsp;${activity.startDate}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;" id="detail-endDate">
            <b>&nbsp;${activity.endDate}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">成本</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;" id="detail-cost"><b>&nbsp;${activity.cost}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;" id="detail-createBy">
            <b>&nbsp;${activity.createBy}&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;">${activity.createTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;" id="detail-editBy"><b>&nbsp;${activity.editBy}&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;">${activity.editTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;" id="detail-description">
            <b>
                &nbsp;${activity.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div style="position: relative; top: 30px; left: 40px;" id="remarkBody">
    <div class="page-header">
        <h4>备注</h4>
    </div>



    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>
<div style="height: 200px;"></div>
</body>
</html>