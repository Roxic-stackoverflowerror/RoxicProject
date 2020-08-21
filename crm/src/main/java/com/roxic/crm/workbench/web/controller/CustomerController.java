package com.roxic.crm.workbench.web.controller;

import com.roxic.crm.settings.domain.User;
import com.roxic.crm.settings.service.Impl.UserServiceImpl;
import com.roxic.crm.settings.service.UserService;
import com.roxic.crm.utils.DateTimeUtil;
import com.roxic.crm.utils.PrintJson;
import com.roxic.crm.utils.ServiceFactory;
import com.roxic.crm.utils.UUIDUtil;
import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.domain.Contacts;
import com.roxic.crm.workbench.domain.Customer;
import com.roxic.crm.workbench.domain.CustomerRemark;
import com.roxic.crm.workbench.domain.Tran;
import com.roxic.crm.workbench.service.ContactsService;
import com.roxic.crm.workbench.service.CustomerService;
import com.roxic.crm.workbench.service.impl.ContactsServiceImpl;
import com.roxic.crm.workbench.service.impl.CustomerServiceImpl;
import org.apache.ibatis.transaction.Transaction;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

public class CustomerController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到客户控制器");

        String path = request.getServletPath();
        if ("/workbench/customer/pageList.do".equals(path)) {
            pageList(request, response);

        } else if ("/workbench/customer/getUserList.do".equals(path)) {

            getUserList(request, response);
        }else if ("/workbench/customer/save.do".equals(path)) {

            save(request, response);
        }else if ("/workbench/customer/delete.do".equals(path)) {

            delete(request, response);
        }else if ("/workbench/customer/getUserListAndCustomer.do".equals(path)) {

            getUserListAndCustomer(request, response);
        }else if ("/workbench/customer/update.do".equals(path)) {

            update(request, response);
        }else if ("/workbench/customer/detail.do".equals(path)) {

            detail(request, response);
        }else if ("/workbench/customer/saveRemark.do".equals(path)) {

            saveRemark(request, response);
        }else if ("/workbench/customer/updateRemark.do".equals(path)) {

            updateRemark(request, response);
        }else if ("/workbench/customer/getRemarkListByCuid.do".equals(path)) {

            getRemarkListByCuid(request, response);
        }else if ("/workbench/customer/removeRemark.do".equals(path)) {

            removeRemark(request, response);
        }else if ("/workbench/customer/getTranListByCuid.do".equals(path)) {

            getTranListByCuid(request, response);
        }else if ("/workbench/customer/getContactsListByCuid.do".equals(path)) {

            getContactsListByCuid(request, response);
        }else if ("/workbench/customer/saveContacts.do".equals(path)) {

            saveContacts(request, response);
        }else if ("/workbench/customer/xxx.do".equals(path)) {

            //xxx(request, response);
        }
    }

    private void saveContacts(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("在客户详细页添加其联系人");
        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String source = request.getParameter("source");
        String customerId = request.getParameter("customerId");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String email = request.getParameter("email");
        String mphone = request.getParameter("mphone");
        String job = request.getParameter("job");
        String birth = request.getParameter("birth");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        Contacts contacts = new Contacts();
        contacts.setId(id);
        contacts.setOwner(owner);
        contacts.setSource(source);
        contacts.setCustomerId(customerId);
        contacts.setFullname(fullname);
        contacts.setAppellation(appellation);
        contacts.setEmail(email);
        contacts.setMphone(mphone);
        contacts.setJob(job);
        contacts.setBirth(birth);
        contacts.setCreateTime(createTime);
        contacts.setCreateBy(createBy);
        contacts.setDescription(description);
        contacts.setContactSummary(contactSummary);
        contacts.setNextContactTime(nextContactTime);
        contacts.setAddress(address);
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.saveContacts(contacts);
        PrintJson.printJsonFlag(response,flag);

    }

    private void getContactsListByCuid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据客户id查询相关联系人");
        String id = request.getParameter("customerId");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<Contacts> contactsList = customerService.getContactsListByCuid(id);
        PrintJson.printJsonObj(response,contactsList);
    }

    private void getTranListByCuid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据客户id查询相关交易");
        String id = request.getParameter("customerId");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<Tran> tranList = customerService.getTranListByCuid(id);
        PrintJson.printJsonObj(response,tranList);

    }

    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行修改备注操作");
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "1";

        CustomerRemark cur = new CustomerRemark();
        cur.setId(id);
        cur.setNoteContent(noteContent);
        cur.setEditTime(editTime);
        cur.setEditBy(editBy);
        cur.setEditFlag(editFlag);

        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.updateRemark(cur);
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("success",flag);
        map.put("cur",cur);
        PrintJson.printJsonObj(response,map);
    }

    private void getRemarkListByCuid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据客户的id，取得备注信息列表");

        String customerId = request.getParameter("customerId");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<CustomerRemark> arList = customerService.getRemarkListByCuid(customerId);
        PrintJson.printJsonObj(response,arList);
    }

    private void removeRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("删除备注操作");
        String id = request.getParameter("id");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.removeRemark(id);
        PrintJson.printJsonFlag(response,flag);
    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("添加备注操作");
        String noteContent = request.getParameter("noteContent");
        String customerId = request.getParameter("customerId");
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "0";

        CustomerRemark cur = new CustomerRemark();
        cur.setId(id);
        cur.setNoteContent(noteContent);
        cur.setCustomerId(customerId);
        cur.setCreateTime(createTime);
        cur.setCreateBy(createBy);
        cur.setEditFlag(editFlag);

        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.saveRemark(cur);
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("success",flag);
        map.put("cur",cur);
        PrintJson.printJsonObj(response,map);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到客户活动详细信息页");
        String id = request.getParameter("id");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        Customer customer = customerService.detail(id);

        request.setAttribute("customer",customer);
        request.getRequestDispatcher("/workbench/customer/detail.jsp").forward(request,response);
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行客户删除操作");
        String[] ids = request.getParameterValues("id");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.delete(ids);
        PrintJson.printJsonFlag(response,flag);
    }

    private void update(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进行客户的修改");
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        Customer customer = new Customer();
        customer.setId(id);
        customer.setName(name);
        customer.setOwner(owner);
        customer.setPhone(phone);
        customer.setWebsite(website);
        customer.setEditBy(editBy);
        customer.setEditTime(editTime);
        customer.setDescription(description);
        customer.setContactSummary(contactSummary);
        customer.setNextContactTime(nextContactTime);
        customer.setAddress(address);

        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.update(customer);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getUserListAndCustomer(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入查询用户和客户的操作");
        String id = request.getParameter("id");
        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        //返回Map
        Map<String,Object> map = customerService.getUserListAndCustomer(id);
        PrintJson.printJsonObj(response,map);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行客户添加操作");
        String id = UUIDUtil.getUUID();
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        Customer customer = new Customer();
        customer.setId(id);
        customer.setName(name);
        customer.setOwner(owner);
        customer.setPhone(phone);
        customer.setWebsite(website);
        customer.setCreateBy(createBy);
        customer.setCreateTime(createTime);
        customer.setDescription(description);
        customer.setContactSummary(contactSummary);
        customer.setNextContactTime(nextContactTime);
        customer.setAddress(address);

        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        boolean flag = customerService.save(customer);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("取得用户信息列表");

        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();

        PrintJson.printJsonObj(response,userList);
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行到查询客户信息列表操作");
        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String pageNoStr =request.getParameter("pageNo");
        String pageSizeStr =request.getParameter("pageSize");

        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //LIMIT x,y 略过x条，查y条。
        //计算出略过的记录数
        int skipCount = (pageNo - 1) * pageSize;
        //打包
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("website",website);
        map.put("owner",owner);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        CustomerService customerService = (CustomerService) ServiceFactory.getService(new CustomerServiceImpl());

        PageListVO<Customer> vo = customerService.pageList(map);
        PrintJson.printJsonObj(response,vo);
    }

}
