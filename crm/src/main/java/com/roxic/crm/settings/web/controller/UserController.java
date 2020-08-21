package com.roxic.crm.settings.web.controller;

import com.roxic.crm.settings.domain.User;
import com.roxic.crm.settings.service.Impl.UserServiceImpl;
import com.roxic.crm.settings.service.UserService;
import com.roxic.crm.utils.MD5Util;
import com.roxic.crm.utils.PrintJson;
import com.roxic.crm.utils.ServiceFactory;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

public class UserController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response){
        System.out.println("进入用户控制器");
        String path = request.getServletPath();
        if("/settings/user/login.do".equals(path)){
            login(request,response);
        }else if ("/settings/user/xxx.do".equals(path)){


        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入登录验证操作");
        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        //用MD5将密码从明文变成暗文;
        loginPwd = MD5Util.getMD5(loginPwd);
        //接收IP地址
        String ip = request.getRemoteAddr();
        System.out.println("=====ip====="+ip);

        //创建service对象,使用代理的方式
        UserService userService = (UserService)ServiceFactory.getService(new UserServiceImpl());

        try {
            User user = userService.login(loginAct, loginPwd, ip);

            request.getSession().setAttribute("user", user);

            //如果程序执行到此处，说明业务层没有为controller抛出任何异常
            //表示登录成功,给前端{"success":true}
            PrintJson.printJsonFlag(response,true);

        }catch (Exception e) {
            //一旦捕捉到异常，说明业务层登录失败，为controller抛出了异常，表示登录失败
            e.printStackTrace();
            String msg = e.getMessage();
            /*
            * 此时，controller需要为ajax提供多个信息。
            *   1. 将多项信息打包成map
            *   2. 将多项信息存到一个对象（Vo）里
            *       private boolean success;
            *       private String msg;
            *
            * 如果对于展现的信息将来还会大量使用，创建个vo类比较好，反之用map
            * */
            Map<String,Object> map = new HashMap<String,Object>();
            map.put("success",false);
            map.put("msg",msg);
            PrintJson.printJsonObj(response,map);
        }

    }
}
