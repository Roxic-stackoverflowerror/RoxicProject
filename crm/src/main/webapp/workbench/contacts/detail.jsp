<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

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

            //给备注保存按钮添加事件
            $("#saveRemarkBtn").click(function () {
                $.ajax({
                    url: "workbench/contacts/saveRemark.do",
                    data: {
                        "noteContent": $.trim($("#remark").val()),
                        "contactsId": "${contacts.id}"
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        /*
                        * data
                        *       {"success":true/false,"conr":{备注}}
                        * */
                        if (data.success) {

                            //清空文本域
                            $("#remark").val("");

                            //添加成功，在文本域上放加个div
                            var html = "";

                            html += '<div id="' + data.conr.id + '" class="remarkDiv" style="height: 60px;">';
                            html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                            html += '<div style="position: relative; top: -40px; left: 40px;">';
                            html += '<h5>' + data.conr.noteContent + '</h5>';
                            html += '<font color="gray">线索</font> <font color="gray">-</font> <b>${contacts.fullname} ${contacts.appellation}</b>';
                            html += '<small style="color: gray;"> ' + data.conr.createTime + ' 由' + data.conr.createBy + '</small>';
                            html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                            html += '<a class="myHref" href="javascript:void(0);" "><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #0000FF;"></span></a>';
                            html += ' &nbsp;&nbsp;&nbsp;&nbsp;';
                            html += '<a class="myHref" href="javascript:void(0);" onclick="removeRemark(\'' + data.conr.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
                            html += '</div>';
                            html += '</div>';
                            html += '</div>';

                            $("#remarkDiv").before(html);

                        } else {
                            alert("添加备注失败！")
                        }
                    }
                })
            })

            //为更新按钮绑定事件
            $("#updateRemarkBtn").click(function () {

                var id = $("#remarkId").val();
                $.ajax({
                    url: "workbench/contacts/updateRemark.do",
                    data: {

                        "id": id,
                        "noteContent": $.trim($("#noteContent").val())

                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {

                        /*
                        * data
                        *       {"sueccess":true/false,"cr":{备注对象}}
                        * */
                        if (data.success) {

                            //更新div相应的信息，noteContent,editTime,editBy
                            $("#e" + id).html(data.conr.noteContent);
                            $("#roxic" + id).html(data.conr.editTime + ' 由' + data.conr.editBy);
                            //更新内容之后，关闭模态窗口
                            $("#editRemarkModal").modal("hide");
                        } else {
                            alert("备注修改失败！");
                        }

                    }
                })
            })

            showRemarkList();

            $("#remarkBody").on("mouseover", ".remarkDiv", function () {
                $(this).children("div").children("div").show();
            })
            $("#remarkBody").on("mouseout", ".remarkDiv", function () {
                $(this).children("div").children("div").hide();
            })

            //为关联按钮绑定事件，执行关联表的添加操作
            $("#boundBtn").click(function () {
                var $xz = $("input[name=xz]:checked");
                if ($xz.length == 0) {
                    alert("请选择需要关联的市场活动");
                } else {
                    var param = "contactsId=${contacts.id}&";
                    for (var i = 0; i < $xz.length; i++) {
                        param += "activityId=" + $($xz[i]).val();
                        if (i != $xz.length - 1) {
                            param += "&";
                        }
                    }


                    $.ajax({
                        url: "workbench/contacts/bound.do",
                        data: param,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            /*data
                            *       {"success":true/false}
                            * */
                            if (data.success) {

                                showActivityList();
                                $("#activityName").val("");
                                $("#bundActivityModal").modal("hide");

                            } else {
                                alert("关联失败！")
                            }
                        }
                    })
                }
            })

            $("#qx").click(function () {
                $("input[name=xz]").prop("checked", this.checked);
            })
            $("#activitySearchBody").on("click", $("input[name=xz]"), function () {
                //alert(666);
                $("#qx").prop("checked", $("input[name=xz]").length == $("input[name=xz]:checked").length)
            })

            showActivityList();

            //为关联市场活动模态窗口中的搜索框绑定事件，回车查询
            $("#activityName").keydown(function (event) {
                if (event.keyCode == 13) {
                    //alert(123);
                    $.ajax({
                        url: "workbench/contacts/getActivityListByNameAndNotByContactsId.do",
                        data: {
                            "activityName": $.trim($("#activityName").val()),
                            "contactsId": "${contacts.id}"

                        },
                        type: "get",
                        dataType: "json",
                        success: function (data) {
                            var html = "";
                            $.each(data, function (i, n) {
                                html += '<tr>';
                                html += '<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
                                html += '<td>' + n.name + '</td>';
                                html += '<td>' + n.startDate + '</td>';
                                html += '<td>' + n.endDate + '</td>';
                                html += '<td>' + n.owner + '</td>';
                                html += '</tr>';
                            })

                            $("#activitySearchBody").html(html);
                        }
                    })


                    //展现列表后，要把模态窗口默认的回车行为禁用
                    return false;
                }
            })

            $("#activityBoundBtn").click(function () {
                $("#qx").prop("checked", false);
                //alert(123);
                $.ajax({
                    url: "workbench/contacts/getActivityListByNameAndNotByContactsId.do",
                    data: {
                        "activityName": $.trim($("#activityName").val()),
                        "contactsId": "${contacts.id}"

                    },
                    type: "get",
                    dataType: "json",
                    success: function (data) {
                        var html = "";
                        $.each(data, function (i, n) {
                            html += '<tr>';
                            html += '<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
                            html += '<td>' + n.name + '</td>';
                            html += '<td>' + n.startDate + '</td>';
                            html += '<td>' + n.endDate + '</td>';
                            html += '<td>' + n.owner + '</td>';
                            html += '</tr>';
                        })

                        $("#activitySearchBody").html(html);
                        $("#bundActivityModal").modal("show");
                    }
                })


            })

            showTranList();

            $("#removeTranBtn").click(function () {
                $.ajax({
                    url: "workbench/transaction/remove.do",
                    data: {
                        "tranId": "${tran.id}"
                    },
                    type: "",
                    dataType: "json",
                    success: function (data) {

                    }
                })
            })

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

                var id = "${contacts.id}";

                $.ajax({
                    url: "workbench/contacts/getUserListAndContacts.do",
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
                        *       {"uList":[{用户1},{用户2},{用户3}...],"clue":{线索}}
                        * */

                        //所有者下拉框
                        var html = "<option></option>";
                        $.each(data.uList, function (i, n) {
                            html += "<option value='" + n.id + "'>" + n.name + "</option>"
                        })

                        $("#edit-owner").html(html);

                        //处理其他内容
                        $("#edit-id").val(data.contacts.id);
                        $("#edit-owner").val(data.contacts.owner);
                        $("#edit-customerName").val(data.contacts.customerId);
                        $("#edit-appellation").val(data.contacts.appellation);
                        $("#edit-fullname").val(data.contacts.fullname);
                        $("#edit-job").val(data.contacts.job);
                        $("#edit-email").val(data.contacts.email);
                        $("#edit-birth").val(data.contacts.birth);
                        $("#edit-mphone").val(data.contacts.mphone);
                        $("#edit-source").val(data.contacts.source);
                        $("#edit-description").val(data.contacts.description);
                        $("#edit-contactSummary").val(data.contacts.contactSummary);
                        $("#edit-nextContactTime").val(data.contacts.nextContactTime);
                        $("#edit-address").val(data.contacts.address);

                        //所有值填进去后，打开模态窗口
                        $("#editContactsModal").modal("show");

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
                    url: "workbench/contacts/update.do",
                    data: {

                        "id": $.trim($("#edit-id").val()),
                        "owner": $.trim($("#edit-owner").val()),
                        "appellation": $.trim($("#edit-appellation").val()),
                        "fullname": $.trim($("#edit-fullname").val()),
                        "job": $.trim($("#edit-job").val()),
                        "email": $.trim($("#edit-email").val()),
                        "mphone": $.trim($("#edit-mphone").val()),
                        "birth": $.trim($("#edit-birth").val()),
                        "source": $.trim($("#edit-source").val()),
                        "description": $.trim($("#edit-description").val()),
                        "contactSummary": $.trim($("#edit-contactSummary").val()),
                        "nextContactTime": $.trim($("#edit-nextContactTime").val()),
                        "address": $.trim($("#edit-address").val())

                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.success) {

                            window.location.href = "workbench/contacts/detail.do?id=" + "${contacts.id}";
                            $("#editCustomerModal").modal("hide");
                        } else {
                            alert("修改客户失败！");
                        }
                    }
                })
            })

            $("#deleteBtn").click(function () {

                    //增加个确认框
                    if(confirm("确定删除该联系人吗?")){

                        //有可能选中一个或者选择多个
                        //alert(666);
                        //workbench/activity/delete.do?id=xxxxxxxxxxxx&id=xxxxxxxxxxxx&id=xxxxxxxxxxxxx
                        //拼接参数
                        //遍历出jquery对象中所有的dom对象
                        var id = "${contacts.id}";

                        //alert(param);

                        $.ajax({
                            url:"workbench/contacts/delete.do",
                            data:{
                                "id": id
                            },
                            type:"post",
                            dataType:"json",
                            success: function (data) {
                                /*data
                                *       {"success":true/false}
                                * */
                                if(data.success){

                                    //删除成功后
                                    window.location.href = "workbench/contacts/index.jsp";


                                }else {
                                    alert("删除失败！")
                                }
                            }
                        })

                    }



            })

        });//load事件末尾
        function removeTran(id) {
            if (confirm("请确认删除该交易！")) {
                $.ajax({
                    url: "workbench/transaction/remove.do",
                    data: {
                        "tranId": id
                    },
                    type: "get",
                    dataType: "json",
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
                url: "workbench/contacts/getTranListByConid.do",
                data: {
                    "contactsId": "${contacts.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    var html = "";
                    $.each(data, function (i, n) {
                        html += '<tr>';
                        html += '<td><a href=workbench/transaction/detail.do?id=' + n.id + ' style="text-decoration: none;">' + n.name + '</a></td>';
                        html += '<td>' + n.money + '</td>';
                        html += '<td>' + n.stage + '</td>';
                        html += '<td>' + n.expectedDate + '</td>';
                        html += '<td>' + n.type + '</td>';
                        html += '<td><a href="javascript:void(0);" onclick="removeTran(\'' + n.id + '\')" style="text-decoration: none;" id="' + n.id + '"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
                        html += '</tr>';
                    })

                    $("#tranBody").html(html);
                }
            })
        }

        function showActivityList() {
            $.ajax({
                url: "workbench/contacts/getActivityListByContactsId.do",
                data: {
                    "contactsId": "${contacts.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    var html = "";
                    $.each(data, function (i, n) {
                        html += '<tr>';
                        html += '<td>' + n.name + '</td>';
                        html += '<td>' + n.startDate + '</td>';
                        html += '<td>' + n.endDate + '</td>';
                        html += '<td>' + n.owner + '</td>';
                        html += '<td><a href="javascript:void(0);" onclick="unbound(\'' + n.id + '\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>';
                        html += '</tr>';

                    })
                    $("#activityBody").html(html);
                }
            })

        }

        function unbound(id) {
            if (confirm("是否确认解除关联？")) {
                $.ajax({
                    url: "workbench/contacts/unbound.do",
                    data: {
                        "id": id
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.success) {
                            showActivityList();
                        } else {
                            alert("解除关联失败！")
                        }
                    }
                })
            }

        }

        //展示备注列表
        function showRemarkList() {

            $.ajax({
                url: "workbench/contacts/getRemarkListByConid.do",
                data: {
                    "contactsId": "${contacts.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {

                    /*
                    * data
                    *       [{备注1},{备注2},{备注3},{备注4}...]
                    * */
                    var html = "";

                    $.each(data, function (i, n) {
                        html += '<div id="' + n.id + '" class="remarkDiv" style="height: 60px;">';
                        html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                        html += '<div style="position: relative; top: -40px; left: 40px;">';
                        html += '<h5 id="e' + n.id + '">' + n.noteContent + '</h5>';
                        html += '<font color="gray">联系人</font> <font color="gray">-</font> <b>${contacts.fullname} ${contacts.appellation}</b>';
                        html += '<small style="color: gray;" id="roxic' + n.id + '"> ' + (n.editFlag == 0 ? n.createTime : n.editTime) + ' 由' + (n.editFlag == 0 ? n.createBy : n.editBy) + '</small>';
                        html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                        html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #0000FF;"></span></a>';
                        html += ' &nbsp;&nbsp;&nbsp;&nbsp;';
                        html += '<a class="myHref" href="javascript:void(0);" onclick="removeRemark(\'' + n.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
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
                url: "workbench/contacts/removeRemark.do",
                data: {

                    "id": id
                },
                type: "post",
                dataType: "json",
                success: function (data) {

                    /*
                    * data:{"success":true/false}
                    * */
                    if (data.success) {
                        //以下方法不行，使用的是before，会追加
                        //showRemarkList();

                        //找到需要删除的div
                        $("#" + id).remove();
                    } else {
                        alert("删除备注失败！")
                    }
                }
            })
        }

        function editRemark(id) {
            //alert(id);
            //将模态窗口中的隐藏域中的id赋值
            $("#remarkId").val(id);
            var noteContent = $("#e" + id).html();
            $("#editRemarkModal").modal("show");
            $("#noteContent").val(noteContent);
        }

    </script>

</head>
<body>


<!-- 联系人和市场活动关联的模态窗口 -->
<div class="modal fade" id="bundActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">关联市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input type="text" class="form-control" id="activityName" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable1" class="table table-hover"
                       style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td><input type="checkbox" id="qx"/></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                        <td></td>
                    </tr>
                    </thead>
                    <tbody id="activitySearchBody">
                    <%--<tr>
                        <td><input type="checkbox"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>
                    <tr>
                        <td><input type="checkbox"/></td>
                        <td>发传单</td>
                        <td>2020-10-10</td>
                        <td>2020-10-20</td>
                        <td>zhangsan</td>
                    </tr>--%>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="boundBtn">关联</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改联系人的模态窗口 -->
<div class="modal fade" id="editContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <input type="hidden" id="edit-id">
                    <div class="form-group">
                        <label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-owner">

                            </select>
                        </div>
                        <label for="edit-clueSource" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-source">
                                <option></option>
                                <c:forEach items="${source}" var="roxic3">
                                    <option value="${roxic3.value}">${roxic3.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-fullname">
                        </div>
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-appellation">
                                <option></option>
                                <c:forEach items="${appellation}" var="roxic1">
                                    <option value="${roxic1.value}">${roxic1.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job">
                        </div>
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email">
                        </div>
                        <label for="edit-birth" class="col-sm-2 control-label">生日</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="edit-birth" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-customerName"
                                   placeholder="支持自动补全，输入客户不存在则新建" readonly>
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
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
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

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.location.href='workbench/contacts/index.jsp';"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${contacts.fullname}&nbsp;${contacts.appellation}
            <small> - ${contacts.customerId}</small>
        </h3>
    </div>
    <div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
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
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${contacts.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${contacts.source}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${contacts.customerId}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">姓名</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;">
            <b>${contacts.fullname}&nbsp;${contacts.appellation}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">邮箱</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${contacts.email}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${contacts.mphone}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">职位</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${contacts.job}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">生日</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${contacts.birth}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>&nbsp;${contacts.createBy}&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;">&nbsp;${contacts.createTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>&nbsp;${contacts.editBy}&nbsp;&nbsp;</b>
            <small style="font-size: 10px; color: gray;">&nbsp;${contacts.editTime}</small>
        </div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                &nbsp;${contacts.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                &nbsp;${contacts.contactSummary}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${contacts.nextContactTime}</b>
        </div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                &nbsp;${contacts.address}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>
<!-- 备注 -->
<div style="position: relative; top: 20px; left: 40px;" id="remarkBody">
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
            <a href="javascript:void(0);"
               onclick="window.location.href='workbench/transaction/add.do?name=${contacts.customerId}';"
               style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
        </div>
    </div>
</div>

<!-- 市场活动 -->
<div>
    <div style="position: relative; top: 60px; left: 40px;">
        <div class="page-header">
            <h4>市场活动</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                    <td>所有者</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="activityBody">
                <%--<tr>
                    <td><a href="activity/detail.jsp" style="text-decoration: none;">发传单</a></td>
                    <td>2020-10-10</td>
                    <td>2020-10-20</td>
                    <td>zhangsan</td>
                    <td><a href="javascript:void(0);" data-toggle="modal" data-target="#unbundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>
                </tr>--%>
                </tbody>
            </table>
        </div>

        <div>
            <a href="javascript:void(0);" id="activityBoundBtn" style="text-decoration: none;"><span
                    class="glyphicon glyphicon-plus"></span>关联市场活动</a>
        </div>
    </div>
</div>


<div style="height: 200px;"></div>
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
</body>
</html>