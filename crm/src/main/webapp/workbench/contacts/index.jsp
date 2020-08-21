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

    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
    <script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

    <script type="text/javascript">

        $(function () {

            $("#create-customerName").typeahead({
                source: function (query, process) {
                    $.get(
                        "workbench/transaction/getCustomerName.do",
                        { "name" : query },
                        function (data) {
                            //alert(data);
                            /*
                            * data
                            *       [{客户1},{客户2},{客户3}...](里面放的是名称的string)
                            * */
                            process(data);
                        },
                        "json"
                    );
                },
                delay: 500
            });
            pageList(1, 5);


            $(".time").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });
            //定制字段
            $("#definedColumns > li").click(function (e) {
                //防止下拉菜单消失
                e.stopPropagation();
            });

            //为搜索按钮绑定事件
            $("#searchBtn").click(function () {
                /*
                * 点击查询按钮的时候，应该将搜索框中的内容保存起来,保存到隐藏域中
                *
                * */

                $("#hidden-fullname").val($.trim($("#search-fullname").val()));
                $("#hidden-customer").val($.trim($("#search-customer").val()));
                $("#hidden-birth").val($.trim($("#search-birth").val()));
                $("#hidden-source").val($.trim($("#search-source").val()));
                $("#hidden-owner").val($.trim($("#search-owner").val()));
                pageList(1, 5);
            })


            //为创建按钮绑定，打开添加操作的模态窗口
            $("#addBtn").click(function () {

                $("#create-source").val("");
                $("#create-fullname").val("");
                $("#create-appellation").val("");
                $("#create-job").val("");
                $("#create-email").val("");
                $("#create-mphone").val("");
                $("#create-birth").val("");
                $("#create-customerName").val("");
                $("#create-description").val("");
                $("#create-contactSummary").val("");
                $("#create-nextContactTime").val("");
                $("#create-address").val("");

                $.ajax({
                    url:"workbench/clue/getUserList.do",
                    type:"get",
                    dataType:"json",
                    success: function (data) {
                        var html = "<option></option>";
                        $.each(data,function(i,n){
                            html += "<option value='"+n.id+"'>"+n.name+"</option>";
                        })

                        $("#create-owner").html(html);

                        var id = "${user.id}"
                        $("#create-owner").val(id);

                        $("#createContactsModal").modal("show");
                    }
                })
            })

            //为保存按钮绑定事件
            $("#saveBtn").click(function () {
                $.ajax({
                    url:"workbench/contacts/save.do",
                    data:{

                        "fullname":$.trim($("#create-fullname").val()),
                        "appellation":$.trim($("#create-appellation").val()),
                        "owner":$.trim($("#create-owner").val()),
                        "customerName":$.trim($("#create-customerName").val()),
                        "job":$.trim($("#create-job").val()),
                        "email":$.trim($("#create-email").val()),
                        "birth":$.trim($("#create-birth").val()),
                        "mphone":$.trim($("#create-mphone").val()),
                        "source":$.trim($("#create-source").val()),
                        "description":$.trim($("#create-description").val()),
                        "contactSummary":$.trim($("#create-contactSummary").val()),
                        "nextContactTime":$.trim($("#create-nextContactTime").val()),
                        "address":$.trim($("#create-address").val())

                    },
                    type:"post",
                    dataType:"json",
                    success: function (data) {
                        /*
                        * data:
                        *       {"success":true/false}
                        * */
                        if(data.success){
                            //刷新列表

                            //pageList()
                            $("#createContactsModal").modal("hide");
                            pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
                        }else {
                            alert("添加联系人失败！")
                        }
                    }
                })
            })

            $("#qx").click(function () {
                $("input[name=xz]").prop("checked",this.checked);
            })
            $("#contactsBody").on("click",$("input[name=xz]"),function () {
                //alert(666);
                $("#qx").prop("checked",$("input[name=xz]").length == $("input[name=xz]:checked").length)
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

                var $xz = $("input[name=xz]:checked");
                if ($xz.length == 0) {
                    alert("请选择需要修改的记录!")
                } else if ($xz.length > 1) {
                    alert("一次只能修改一条记录！")
                } else {
                    var id = $xz.val();

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
                            *       {"uList":[{用户1},{用户2},{用户3}...],"contacts":{线索}}
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
                }
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

                            pageList($("#contactsPage").bs_pagination('getOption', 'currentPage')
                                , $("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));

                            $("#editContactsModal").modal("hide");
                        } else {
                            alert("修改联系人失败！");
                        }
                    }
                })
            })

            $("#deleteBtn").click(function () {
                //找到复选框中所有选中的复选框的jquery对象
                var $xz = $("input[name=xz]:checked");
                if($xz.length == 0){
                    //没有选中任何复选框
                    alert("请选择需要删除的联系人!")
                }else {

                    //增加个确认框
                    if(confirm("确定删除所选中的联系人吗?")){

                        //有可能选中一个或者选择多个
                        //alert(666);
                        //workbench/activity/delete.do?id=xxxxxxxxxxxx&id=xxxxxxxxxxxx&id=xxxxxxxxxxxxx
                        //拼接参数
                        //遍历出jquery对象中所有的dom对象
                        var param = "";
                        for(var i = 0;i < $xz.length;i++){
                            param += "id=" + $($xz[i]).val();
                            if(i != $xz.length-1){
                                param += "&";
                            }
                        }

                        //alert(param);

                        $.ajax({
                            url:"workbench/contacts/delete.do",
                            data:param,
                            type:"post",
                            dataType:"json",
                            success: function (data) {
                                /*data
                                *       {"success":true/false}
                                * */
                                if(data.success){

                                    //删除成功后
                                    pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));


                                }else {
                                    alert("删除失败！")
                                }
                            }
                        })

                    }


                }
            })

        });//load事件末尾

        function pageList(pageNo, pageSize) {

            //查询前，将隐藏域中保存的信息取出，赋给搜索框
            $("#search-fullname").val($.trim($("#hidden-fullname").val()));
            $("#search-customer").val($.trim($("#hidden-customer").val()));
            $("#search-birth").val($.trim($("#hidden-birth").val()));
            $("#search-source").val($.trim($("#hidden-source").val()));
            $("#search-owner").val($.trim($("#hidden-owner").val()));

            $("#qx").prop("checked", false);
            //alert("展示列表信息");
            $.ajax({
                url: "workbench/contacts/pageList.do",
                data: {

                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "fullname": $.trim($("#search-fullname").val()),
                    "customer": $.trim($("#search-customer").val()),
                    "birth": $.trim($("#search-birth").val()),
                    "source": $.trim($("#search-source").val()),
                    "owner": $.trim($("#search-owner").val())

                },
                type: "get",
                dataType: "json",
                success: function (data) {

                    /*
                    * data
                    *   我需要的：
                    *   [{线索1}，{线索2}，{线索3}...]
                    *
                    *   分页插件需要的：
                    *   查询出来的总记录数 {"total":100}
                    *   {"total":100 , "dataList":[{线索1}，{线索2}，{线索3}...]}
                    * */

                    var html = "";

                    $.each(data.dataList, function (i, n) {

                        html += '<tr class="active">';
                        html += '<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
                        html += '<td><a style="text-decoration: none; cursor: pointer;"onclick="window.location.href=\'workbench/contacts/detail.do?id=' + n.id + '\';">' + n.fullname + '</a></td>';
                        html += '<td>' + n.customerId + '</td>';
                        html += '<td>' + n.owner + '</td>';
                        html += '<td>' + n.source + '</td>';
                        html += '<td>' + n.birth + '</td>';
                        html += '</tr>';

                    })

                    $("#contactsBody").html(html);

                    //计算总页数
                    var totalPages = data.total % pageSize == 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;

                    //数据处理完毕，使用分页插件
                    $("#contactsPage").bs_pagination({
                        currentPage: pageNo, // 页码
                        rowsPerPage: pageSize, // 每页显示的记录条数
                        maxRowsPerPage: 20, // 每页最多显示的记录条数
                        totalPages: totalPages, // 总页数
                        totalRows: data.total, // 总记录条数

                        visiblePageLinks: 3, // 显示几个卡片

                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        showRowsDefaultInfo: true,

                        //该回调函数，在点击分页组件的时候触发
                        onChangePage: function (event, data) {
                            pageList(data.currentPage, data.rowsPerPage);
                        }
                    });


                }
            })
        }

    </script>
</head>
<body>

<input type="hidden" id="hidden-fullname"/>
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-customer"/>
<input type="hidden" id="hidden-source"/>
<input type="hidden" id="hidden-birth"/>

<!-- 创建联系人的模态窗口 -->
<div class="modal fade" id="createContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="create-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-owner">

                            </select>
                        </div>
                        <label for="create-clueSource" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-source">
                                <option></option>
                                <c:forEach items="${source}" var="roxic3">
                                    <option value="${roxic3.value}">${roxic3.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-fullname">
                        </div>
                        <label for="create-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-appellation">
                                <option></option>
                                <c:forEach items="${appellation}" var="roxic4">
                                    <option value="${roxic4.value}">${roxic4.text}</option>
                                </c:forEach>
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
                            <input type="text" class="form-control" id="create-customerName"
                                   placeholder="支持自动补全，输入客户不存在则新建" value="${name}">
                        </div>
                    </div>

                    <div class="form-group" style="position: relative;">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-description"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime1" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="create-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
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
                <h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <input type="hidden" id="edit-id"/>
                    <div class="form-group">
                        <label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-owner">
                                <option selected>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>
                            </select>
                        </div>
                        <label for="edit-clueSource1" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-source">
                                <option></option>
                                <c:forEach items="${source}" var="roxic5">
                                    <option value="${roxic5.value}">${roxic5.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-fullname" >
                        </div>
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-appellation">
                                <option></option>
                                <c:forEach items="${appellation}" var="roxic6">
                                    <option value="${roxic6.value}">${roxic6.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job" >
                        </div>
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone" >
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email" >
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
                                   placeholder="支持自动补全，输入客户不存在则新建" value="${name}" readonly>
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
                                <input type="text" class="form-control time" id="edit-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address2" class="col-sm-2 control-label">详细地址</label>
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


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>联系人列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">联系人姓名</div>
                        <input class="form-control" type="text" id="search-fullname">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="search-owner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">客户名称</div>
                        <input class="form-control" type="text" id="search-customer">
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="search-source">
                            <option></option>
                            <c:forEach items="${source}" var="roxic4">
                                <option value="${roxic4.value}">${roxic4.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">生日</div>
                        <input class="form-control time" type="text" id="search-birth" readonly>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="searchBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="addBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>


        </div>
        <div style="position: relative;top: 20px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="qx"/></td>
                    <td>联系人姓名</td>
                    <td>客户名称</td>
                    <td>所有者</td>
                    <td>来源</td>
                    <td>生日</td>
                </tr>
                </thead>
                <tbody id="contactsBody">
                <%--<tr>
                    <td><input type="checkbox" /></td>
                    <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四</a></td>
                    <td>动力节点</td>
                    <td>zhangsan</td>
                    <td>广告</td>
                    <td>2000-10-10</td>
                </tr>
                <tr class="active">
                    <td><input type="checkbox" /></td>
                    <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四</a></td>
                    <td>动力节点</td>
                    <td>zhangsan</td>
                    <td>广告</td>
                    <td>2000-10-10</td>
                </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 10px;">
            <div id="contactsPage">

            </div>
        </div>

    </div>

</div>
</body>
</html>