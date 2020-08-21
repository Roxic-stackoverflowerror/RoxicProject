package com.roxic.crm.web.filter;


import javax.servlet.*;
import java.io.IOException;

public class EnCodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("进入过滤字符编码的过滤器");

        //过滤post请求中中文参数乱码
        request.setCharacterEncoding("UTF-8");
        //过滤响应流响应中文乱码
        response.setContentType("text/html;charset=utf-8");

        //放行
        chain.doFilter(request,response);
    }
}
