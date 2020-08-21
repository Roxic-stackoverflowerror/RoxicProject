<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="roxic" uri="http://java.sun.com/jsp/jstl/core" %>
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
            pageList(1, 10);

            //为搜索按钮绑定事件
            $("#searchBtn").click(function () {
                /*
                * 点击查询按钮的时候，应该将搜索框中的内容保存起来,保存到隐藏域中
                *
                * */

                $("#hidden-owner").val($.trim($("#search-owner").val()));
                $("#hidden-name").val($.trim($("#search-name").val()));
                $("#hidden-customer").val($.trim($("#search-customer").val()));
                $("#hidden-stage").val($.trim($("#search-stage").val()));
                $("#hidden-type").val($.trim($("#search-type").val()));
                $("#hidden-source").val($.trim($("#search-source").val()));
                $("#hidden-contacts").val($.trim($("#search-contacts").val()));

                pageList(1, 5);
            })

            $("#qx").click(function () {
                $("input[name=xz]").prop("checked",this.checked);
            })
            $("#tranBody").on("click",$("input[name=xz]"),function () {
                //alert(666);
                $("#qx").prop("checked",$("input[name=xz]").length == $("input[name=xz]:checked").length)
            })

            $("#deleteBtn").click(function () {
                //找到复选框中所有选中的复选框的jquery对象
                var $xz = $("input[name=xz]:checked");
                if($xz.length == 0){
                    //没有选中任何复选框
                    alert("请选择需要删除的记录!")
                }else {

                    //增加个确认框
                    if(confirm("确定删除所选中的交易吗?")){

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
                            url:"workbench/transaction/delete.do",
                            data:param,
                            type:"post",
                            dataType:"json",
                            success: function (data) {
                                /*data
                                *       {"success":true/false}
                                * */
                                if(data.success){
                                    //删除成功后
                                    pageList(1,$("#tranPage").bs_pagination('getOption', 'rowsPerPage'));
                                }else {
                                    alert("删除失败！")
                                }
                            }
                        })

                    }


                }
            })



            $("#editBtn").click(function () {
                var $xz = $("input[name=xz]:checked");
                if ($xz.length == 0) {
                    alert("请选择需要修改的记录!")
                } else if ($xz.length > 1) {
                    alert("一次只能修改一条记录！")
                } else {
                    var id = $xz.val();
                    window.location.href="workbench/transaction/edit.do?id="+id+""
                }
            })


        });//load事件末尾

        function pageList(pageNo, pageSize) {


            //查询前，将隐藏域中保存的信息取出，赋给搜索框
            $("#search-owner").val($.trim($("#hidden-owner").val()));
            $("#search-name").val($.trim($("#hidden-name").val()));
            $("#search-customer").val($.trim($("#hidden-customer").val()));
            $("#search-stage").val($.trim($("#hidden-stage").val()));
            $("#search-type").val($.trim($("#hidden-type").val()));
            $("#search-source").val($.trim($("#hidden-source").val()));
            $("#search-contacts").val($.trim($("#hidden-contacts").val()));
            $("#qx").prop("checked", false);
            //alert("展示列表信息");
            $.ajax({
                url: "workbench/transaction/pageList.do",
                data: {

                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "owner": $.trim($("#search-owner").val()),
                    "name": $.trim($("#search-name").val()),
                    "customer": $.trim($("#search-customer").val()),
                    "stage": $.trim($("#search-stage").val()),
                    "type": $.trim($("#search-type").val()),
                    "source": $.trim($("#search-source").val()),
                    "contacts": $.trim($("#search-contacts").val()),

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
                        html += '<td><a style="text-decoration: none; cursor: pointer;"onclick="window.location.href=\'workbench/transaction/detail.do?id=' + n.id + '\';">' + n.customerId + '-' +n.name + '</a></td>';
                        html += '<td>' + n.customerId + '</td>';
                        html += '<td>' + n.stage + '</td>';
                        html += '<td>' + n.type + '</td>';
                        html += '<td>' + n.owner + '</td>';
                        html += '<td>' + n.source + '</td>';
                        html += '<td>' + n.contactsId + '</td>';
                        html += '</tr>';

                    })

                    $("#tranBody").html(html);

                    //计算总页数
                    var totalPages = data.total % pageSize == 0 ? data.total / pageSize : parseInt(data.total / pageSize) + 1;

                    //数据处理完毕，使用分页插件
                    $("#tranPage").bs_pagination({
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
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-name"/>
<input type="hidden" id="hidden-customer"/>
<input type="hidden" id="hidden-stage"/>
<input type="hidden" id="hidden-type"/>
<input type="hidden" id="hidden-source"/>
<input type="hidden" id="hidden-contacts"/>

<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>交易列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">客户名称</div>
                        <input class="form-control" type="text" id="search-customer">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">交易名称</div>
                        <input class="form-control" type="text" id="search-name">
                    </div>
                </div>

                <div class="form-group">
                <div class="input-group">
                    <div class="input-group-addon">所有者</div>
                    <input class="form-control" type="text" id="search-owner">
                </div>
            </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">阶段</div>
                        <select class="form-control" id="search-stage">
                            <option></option>
                            <roxic:forEach items="${stage}" var="s">
                                <option value="${s.value}">${s.text}</option>
                            </roxic:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">类型</div>
                        <select class="form-control" id="search-type">
                            <option></option>
                            <roxic:forEach items="${transactionType}" var="t">
                                <option value="${t.value}">${t.text}</option>
                            </roxic:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="search-source">
                            <option></option>
                            <roxic:forEach items="${source}" var="sour">
                                <option value="${sour.value}">${sour.text}</option>
                            </roxic:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">联系人名称</div>
                        <input class="form-control" type="text" id="search-contacts">
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="searchBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary"
                        onclick="window.location.href='workbench/transaction/add.do';"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>


        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="qx"/></td>
                    <td>名称</td>
                    <td>客户名称</td>
                    <td>阶段</td>
                    <td>类型</td>
                    <td>所有者</td>
                    <td>来源</td>
                    <td>联系人名称</td>
                </tr>
                </thead>
                <tbody id="tranBody">













                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 20px;">
            <div id="tranPage">

            </div>
        </div>
    </div>


</div>
</body>
</html>