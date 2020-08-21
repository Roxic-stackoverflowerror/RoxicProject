
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
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script>
        $(function () {

            if(window.top != window){
                window.top.location = window.location;
            }

            //页面加载完毕后，清空用户文本框
            $("#loginAct").val("");
            $("#loginPwd").val("");
            //在页面加载完毕后，用户名文本框自动获得焦点
            $("#loginAct").focus();

            //为登录按钮绑定事件，执行登录操作
            $("#submitBtn").click(function () {
                Login();
            })

            //为当前登录窗口绑定敲击键盘事件
            //enent可以获取用户敲的是哪个键
            $(window).keydown(function (event) {
                if(event.keyCode == 13){
                    //用户敲的是回车键（键位码13）
                    Login();
                }
            })
        })

        //封装登录操作验证
        function Login() {
            //alert("登录操作");
            var loginAct = $("#loginAct").val().trim();
            var loginPwd = $("#loginPwd").val().trim();
            //alert(loginAct);alert(loginPwd);
            if(loginAct==""||loginPwd==""){
                $("#msg").html("账号密码不能为空！");
                //如果账号和密码为空，及时强制终止方法
                return false;
            }

            //去后端验证登录相关操作
            $.ajax({
                //注意第一个没有斜杠
                url:"settings/user/login.do",
                data:{
                    "loginAct":loginAct,
                    "loginPwd":loginPwd
                },
                type:"post",
                dataType:"json",
                success: function (data) {
                    /*
                    * data里应该包括：
                    *   "success":true/false
                    *   "msg":哪错了
                    * */
                    if(data.success){
                        //登录成功，跳转到工作台初始页
                        window.location.href = "workbench/index.jsp";
                    }else{
                        $("#msg").html(data.msg);
                    }
                }
            })
        }
    </script>
</head>
<body>
<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
    <img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
</div>
<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
    <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">
        CRM &nbsp;<span style="font-size: 12px;">&copy;Roxic&nbsp;堆栈花园</span></div>
</div>

<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
    <div style="position: absolute; top: 0px; right: 60px;">
        <div class="page-header">
            <h1>登录</h1>
        </div>
        <form action="workbench/index.jsp" class="form-horizontal" role="form">
            <div class="form-group form-group-lg">
                <div style="width: 350px;">
                    <input class="form-control" type="text" placeholder="用户名" id="loginAct">
                </div>
                <div style="width: 350px; position: relative;top: 20px;">
                    <input class="form-control" type="password" placeholder="密码" id="loginPwd">
                </div>
                <div class="checkbox" style="position: relative;top: 30px; left: 10px;">

                    <span id="msg" style="color: red"></span>

                </div>
                <%--
                钮写在form里，默认行为就是提交表单，一定要将按钮设置为button
                按钮触发的行为应该由我们自己写的js代码决定。
                --%>
                <button type="button" class="btn btn-primary btn-lg btn-block"
                        style="width: 350px; position: relative;top: 45px;" id="submitBtn">登录
                </button>
            </div>
        </form>
    </div>
</div>
</body>
</html>