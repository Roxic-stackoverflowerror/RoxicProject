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

        $(function () {

            pageList(1, 5);

            $(".time").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                autoclose: true,
                todayBtn: true,
                pickerPosition: "bottom-left"
            });
            //为创建活动的按钮绑定时间，打开创建的模态窗口
            $("#createActivity").click(function () {


                $("#create-marketActivityName").val("");
                $("#create-startTime").val("");
                $("#create-endTime").val("");
                $("#create-cost").val("");
                $("#create-describe").val("");

                /*
                *
                * 操作模态窗口的方法：
                *   需要操作的模态窗口的jquery对象，调用modal方法，给方法传值   (show：打开    hide：关闭)
                *
                * */
                //找后端，取得用户信息列表，给所有者下拉框放东西
                $.ajax({
                    url: "workbench/activity/getUserList.do",
                    data: {},
                    type: "get",
                    dataType: "json",
                    success: function (data) {
                        var html = "<option> </option>";

                        //每一个遍历得到的n，就是一个user对象
                        $.each(data, function (i, n) {

                            html += "<option value='" + n.id + "'>" + n.name + "</option>"

                        })

                        $("#create-marketActivityOwner").html(html);

                        //取得当前登录的id
                        //在js中用el表达式，el表达式必须要放在字符串里
                        var id = "${user.id}";
                        $("#create-marketActivityOwner").val(id);
                        //所有者下拉框处理完毕，展现模态窗口
                        $("#createActivityModal").modal("show");

                    }
                })

            })

            //为保存按钮绑定时间，执行添加操作
            $("#saveBtn").click(function () {

                $.ajax({
                    url: "workbench/activity/save.do",
                    data: {

                        "owner": $.trim($("#create-marketActivityOwner").val()),
                        "name": $.trim($("#create-marketActivityName").val()),
                        "startDate": $.trim($("#create-startTime").val()),
                        "endDate": $.trim($("#create-endTime").val()),
                        "cost": $.trim($("#create-cost").val()),
                        "description": $.trim($("#create-describe").val())

                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.success) {
                            //添加成功后
                            //刷新市场活动信息列表（局部刷新）

                            //jquery对象转换成dom对象：jquery对象[下标]
                            //dom对象转换成jquery对象：$(dom)

                            //$("#activityAddForm")[0].reset();

                            //关闭添加操作的模态窗口
                            $("#createActivityModal").modal("hide");

                            /*
                            * pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
                            * 操作后停留在当前页
                            * $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
                            * 操作后维持每页设置好的记录数
                            * */
                            pageList(1, $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

                        } else {
                            alert("添加市场活动失败！");
                        }
                    }
                })

            })


            //页面加载完毕后，刷新列表
            //默认展开列表的第一页，每页两条记录

            //为查询按钮绑定时间
            $("#searchBtn").click(function () {

                /*
                * 点击查询按钮的时候，应该将搜索框中的内容保存起来,保存到隐藏域中
                *
                * */

                $("#hidden-name").val($.trim($("#search-name").val()));
                $("#hidden-owner").val($.trim($("#search-owner").val()));
                $("#hidden-startDate").val($.trim($("#search-startDate").val()));
                $("#hidden-endDate").val($.trim($("#search-endDate").val()));

                pageList(1, 5);

            })

            //为全选复选框绑定时间，触发全选操作
            $("#qx").click(function () {
                $("input[name=xz]").prop("checked", this.checked);
            })
            //以下这种做法不行，因为动态生成的内容，不能用普通的绑定事件
            /*$("input[name=xz]").click(function () {

            })*/

            /*
            * 动态生成的内容，要用on来触发事件
            * 语法：
            *       $(需要绑定元素的有效外层元素).on(绑定事件的方式，需要绑定的元素的jquery对象，回调函数)
            * */
            $("#activityBody").on("click", $("input[name=xz]"), function () {
                //alert(666);
                $("#qx").prop("checked", $("input[name=xz]").length == $("input[name=xz]:checked").length)
            })

            //为删除按钮绑定事件，执行市场活动的删除操作
            $("#deleteBtn").click(function () {
                //找到复选框中所有选中的复选框的jquery对象
                var $xz = $("input[name=xz]:checked");
                if ($xz.length == 0) {
                    //没有选中任何复选框
                    alert("请选择需要删除的记录!")
                } else {

                    //增加个确认框
                    if (confirm("确定删除所选中的市场活动吗?")) {

                        //有可能选中一个或者选择多个
                        //alert(666);
                        //workbench/activity/delete.do?id=xxxxxxxxxxxx&id=xxxxxxxxxxxx&id=xxxxxxxxxxxxx
                        //拼接参数
                        //遍历出jquery对象中所有的dom对象
                        var param = "";
                        for (var i = 0; i < $xz.length; i++) {
                            param += "id=" + $($xz[i]).val();
                            if (i != $xz.length - 1) {
                                param += "&";
                            }
                        }

                        //alert(param);

                        $.ajax({
                            url: "workbench/activity/delete.do",
                            data: param,
                            type: "post",
                            dataType: "json",
                            success: function (data) {
                                /*data
                                *       {"success":true/false}
                                * */
                                if (data.success) {

                                    //删除成功后
                                    pageList(1
                                        , $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));


                                } else {
                                    alert("删除失败！")
                                }
                            }
                        })

                    }


                }
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
                                html += "<option value='" + n.id + "'>" + n.name + "</option>"
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
                }
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

                            pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
                                , $("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

                            $("#editActivityModal").modal("hide");
                        } else {
                            alert("修改市场活动失败！");
                        }
                    }
                })
            })

        });//onload末尾

        /*
        * 做前端分页相关操作的基础组件就是pageNo和pageSize
        * pageNo：页码
        * pageSize：每页展现的记录条数
        *
        * pageList就是发出ajax请求，从后台取得最新的列表数据，通过响应数据，局部刷新。
        *
        * 调用pageList方法的时机：
        *   1. 点击左侧市场活动按钮。
        *   2. 添加，修改，删除后，需要刷新列表信息。
        *   3. 点击查询按钮的时候，需要刷新列表信息。
        *   4. 点击分页组件的时候，需要刷新列表信息。
        *
        * 以上有6个时机，上面6个操作执行完毕后，必须调用pageList方法刷新列表。
        * */


        function pageList(pageNo, pageSize) {

            //查询前，将隐藏域中保存的信息取出，赋给搜索框
            $("#search-name").val($.trim($("#hidden-name").val()));
            $("#search-owner").val($.trim($("#hidden-owner").val()));
            $("#search-startDate").val($.trim($("#hidden-startDate").val()));
            $("#search-endDate").val($.trim($("#hidden-endDate").val()));

            $("#qx").prop("checked", false);
            //alert("展示列表信息");
            $.ajax({
                url: "workbench/activity/pageList.do",
                data: {

                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "name": $.trim($("#search-name").val()),
                    "owner": $.trim($("#search-owner").val()),
                    "startDate": $.trim($("#search-startDate").val()),
                    "endDate": $.trim($("#search-endDate").val())

                },
                type: "get",
                dataType: "json",
                success: function (data) {

                    /*
                    * data
                    *   我需要的：
                    *   [{市场活动1}，{市场活动2}，{市场活动3}...]
                    *
                    *   分页插件需要的：
                    *   查询出来的总记录数 {"total":100}
                    *   {"total":100 , "dataList":[{市场活动1}，{市场活动2}，{市场活动3}...]}
                    * */

                    var html = "";

                    $.each(data.dataList, function (i, n) {

                        html += '<tr class="active">';
                        html += '<td><input type="checkbox" name="xz" value="' + n.id + '"/></td>';
                        html += '<td><a style="text-decoration: none; cursor: pointer;"onclick="window.location.href=\'workbench/activity/detail.do?id=' + n.id + '\';">' + n.name + '</a></td>';
                        html += '<td>' + n.owner + '</td>';
                        html += '<td>' + n.startDate + '</td>';
                        html += '<td>' + n.endDate + '</td>';
                        html += '</tr>';

                    })

                    $("#activityBody").html(html);

                    //计算总页数
                    var totalPages = data.total % pageSize == 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;

                    //数据处理完毕，使用分页插件
                    $("#activityPage").bs_pagination({
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

<input type="hidden" id="hidden-name"/>
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-startDate"/>
<input type="hidden" id="hidden-endDate"/>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form" id="activityAddForm">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-marketActivityOwner">
                            </select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="create-startTime" readonly>
                        </div>
                        <label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control time" id="create-endTime" readonly>
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-cost">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <%--

                data-dismiss="modal"：关闭模态窗口

                --%>
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveBtn">保存</button>
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


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>市场活动列表</h3>
        </div>
    </div>
</div>
<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="search-name">
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
                        <div class="input-group-addon">开始日期</div>
                        <input class="form-control time" type="text" id="search-startDate" readonly>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input class="form-control time" type="text" id="search-endDate" readonly>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="searchBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <%--

                    点击创建按钮，观察两个属性和属性值
                    data-toggle="modal"：触发该按钮，将要打开一个模态窗口
                    data-target="#createActivityModal"：表示打开哪个模态窗口，通过#id的方式找到该模态窗口

                    现在通过属性和属性值的方式，打开模态窗口。
                        问题：没有办法对按钮的功能进行扩充。

                    所以开发的时候，对于模态窗口的操作，不能写死在元素里，应该用js代码来操作。

                    data-toggle="modal" data-target="#createActivityModal"

                --%>
                <button type="button" class="btn btn-primary" id="createActivity">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>

        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="qx"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="activityBody">
                <%--                <tr class="active">
                                    <td><input type="checkbox"/></td>
                                    <td><a style="text-decoration: none; cursor: pointer;"
                                           onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                                    <td>zhangsan</td>
                                    <td>2020-10-10</td>
                                    <td>2020-10-20</td>
                                </tr>
                                <tr class="active">
                                    <td><input type="checkbox"/></td>
                                    <td><a style="text-decoration: none; cursor: pointer;"
                                           onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                                    <td>zhangsan</td>
                                    <td>2020-10-10</td>
                                    <td>2020-10-20</td>
                                </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 30px;">
            <div id="activityPage">

            </div>
        </div>

    </div>

</div>
</body>
</html>