package com.roxic.crm.web.filter;

import com.roxic.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("进入是否有登录记录的过滤器");

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();

        //不应该被拦截的资源，放行，让用户登录
        if("/login.jsp".equals(path) || "/settings/user/login.do".equals(path)){

            chain.doFilter(request,response);
        }else{HttpSession session = req.getSession();
            User user = (User) session.getAttribute("user");

            //如果不为null，说明有登录记录
            if(user != null){
                chain.doFilter(request,response);
            }else {
                //重定向到登录页，让用户登录
                /*
                 * 重定向的路径：在开发中，不论是前端还是后端，应该都用绝对路径
                 *   转发的绝对路径比较特殊，前面不加项目名，这种路径也叫内部路径（/login.jsp）
                 *   重定向使用的是传统绝对路径的写法，前面必须以/项目名开头，后面具体资源(/crm/login.jsp)
                 *
                 * 使用重定向的原因：
                 *   转发之后，路径会停留在老路径上，而不会让用户的浏览器更新路径，应该为用户跳转的时候，将浏览器的地址栏也改成登录页。
                 * */
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
            }
        }

        }

}
