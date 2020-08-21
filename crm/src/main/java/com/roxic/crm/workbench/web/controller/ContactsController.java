package com.roxic.crm.workbench.web.controller;

import com.roxic.crm.settings.domain.User;
import com.roxic.crm.settings.service.Impl.UserServiceImpl;
import com.roxic.crm.settings.service.UserService;
import com.roxic.crm.utils.DateTimeUtil;
import com.roxic.crm.utils.PrintJson;
import com.roxic.crm.utils.ServiceFactory;
import com.roxic.crm.utils.UUIDUtil;
import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.domain.*;
import com.roxic.crm.workbench.service.ActivityService;
import com.roxic.crm.workbench.service.ContactsService;
import com.roxic.crm.workbench.service.CustomerService;
import com.roxic.crm.workbench.service.impl.ActivityServiceImpl;
import com.roxic.crm.workbench.service.impl.ContactsServiceImpl;
import com.roxic.crm.workbench.service.impl.CustomerServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ContactsController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到客户控制器");

        String path = request.getServletPath();
        if ("/workbench/contacts/delete.do".equals(path)) {
            delete(request, response);

        } else if ("/workbench/contacts/pageList.do".equals(path)) {

            pageList(request, response);
        }else if ("/workbench/contacts/save.do".equals(path)) {

            save(request, response);
        }else if ("/workbench/contacts/update.do".equals(path)) {

            update(request, response);
        }else if ("/workbench/contacts/getUserListAndContacts.do".equals(path)) {

            getUserListAndContacts(request, response);
        }else if ("/workbench/contacts/detail.do".equals(path)) {

            detail(request, response);
        }else if ("/workbench/contacts/saveRemark.do".equals(path)) {

            saveRemark(request, response);
        }else if ("/workbench/contacts/getRemarkListByConid.do".equals(path)) {

            getRemarkListByConid(request, response);
        }else if ("/workbench/contacts/removeRemark.do".equals(path)) {

            removeRemark(request, response);
        }else if ("/workbench/contacts/updateRemark.do".equals(path)) {

            updateRemark(request, response);
        }else if ("/workbench/contacts/bound.do".equals(path)) {

            bound(request, response);
        }else if ("/workbench/contacts/getActivityListByContactsId.do".equals(path)) {

            getActivityListByContactsId(request, response);
        }else if ("/workbench/contacts/unbound.do".equals(path)) {

            unbound(request, response);
        }else if ("/workbench/contacts/getActivityListByNameAndNotByContactsId.do".equals(path)) {

            getActivityListByNameAndNotByContactsId(request, response);
        }else if ("/workbench/contacts/getTranListByConid.do".equals(path)) {

            getTranListByConid(request, response);
        }else if ("/workbench/contacts/xxx.do".equals(path)) {

            //xxx(request, response);
        }
    }

    private void getTranListByConid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据客户id查询相关交易");
        String id = request.getParameter("contactsId");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        List<Tran> tranList = contactsService.getTranListByConid(id);
        PrintJson.printJsonObj(response,tranList);
    }

    private void getActivityListByNameAndNotByContactsId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("查询市场活动列表，根据名称模糊查，排除已经关联的内容");
        String activityName = request.getParameter("activityName");
        String contactsId = request.getParameter("contactsId");

        Map<String,String> map = new HashMap<String,String> ();
        map.put("activityName",activityName);
        map.put("contactsId",contactsId);
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<Activity> activityList = activityService.getActivityListByNameAndNotByContactsId(map);
        PrintJson.printJsonObj(response,activityList);
    }

    private void getActivityListByContactsId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据联系人id查询关联的市场活动");
        String contactsId = request.getParameter("contactsId");
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        List<Activity> activityList = activityService.getActivityListByContactsId(contactsId);
        PrintJson.printJsonObj(response,activityList);
    }

    private void unbound(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("解除关联操作");
        String id = request.getParameter("id");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.unbound(id);
        PrintJson.printJsonFlag(response,flag);
    }

    private void bound(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("添加关联操作");
        String contactsId = request.getParameter("contactsId");
        String[] activityIds = request.getParameterValues("activityId");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.bound(contactsId,activityIds);
        PrintJson.printJsonFlag(response,flag);
    }

    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行修改备注操作");
        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "1";

        ContactsRemark conr = new ContactsRemark();
        conr.setId(id);
        conr.setNoteContent(noteContent);
        conr.setEditTime(editTime);
        conr.setEditBy(editBy);
        conr.setEditFlag(editFlag);

        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.updateRemark(conr);
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("success",flag);
        map.put("conr",conr);
        PrintJson.printJsonObj(response,map);
    }

    private void getRemarkListByConid(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("根据联系人的id，取得备注信息列表");

        String contactsId = request.getParameter("contactsId");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        List<ContactsRemark> conrList = contactsService.getRemarkListByConid(contactsId);
        PrintJson.printJsonObj(response,conrList);
    }
    private void removeRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("删除备注操作");
        String id = request.getParameter("id");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.removeRemark(id);
        PrintJson.printJsonFlag(response,flag);
    }
    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("添加备注操作");
        String noteContent = request.getParameter("noteContent");
        String contactsId = request.getParameter("contactsId");
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "0";

        ContactsRemark conr = new ContactsRemark();
        conr.setId(id);
        conr.setNoteContent(noteContent);
        conr.setContactsId(contactsId);
        conr.setCreateTime(createTime);
        conr.setCreateBy(createBy);
        conr.setEditFlag(editFlag);

        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.saveRemark(conr);
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("success",flag);
        map.put("conr",conr);
        PrintJson.printJsonObj(response,map);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入联系人的详细信息页");
        String id = request.getParameter("id");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        Contacts contacts = contactsService.detail(id);
        request.setAttribute("contacts",contacts);
        System.out.println(contacts);
        request.getRequestDispatcher("/workbench/contacts/detail.jsp").forward(request,response);
    }

    private void getUserListAndContacts(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入查询用户和联系人的操作");
        String id = request.getParameter("id");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        //返回Map
        Map<String,Object> map = contactsService.getUserListAndContacts(id);
        PrintJson.printJsonObj(response,map);
    }
    private void update(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进行联系人的修改");
        String id = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String birth = request.getParameter("birth");
        String mphone = request.getParameter("mphone");
        String source = request.getParameter("source");
        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        Contacts contacts = new Contacts();
        contacts.setId(id);
        contacts.setFullname(fullname);
        contacts.setAppellation(appellation);
        contacts.setOwner(owner);
        contacts.setJob(job);
        contacts.setEmail(email);
        contacts.setMphone(mphone);
        contacts.setBirth(birth);
        contacts.setSource(source);
        contacts.setEditBy(editBy);
        contacts.setEditTime(editTime);
        contacts.setDescription(description);
        contacts.setContactSummary(contactSummary);
        contacts.setNextContactTime(nextContactTime);
        contacts.setAddress(address);

        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.update(contacts);
        PrintJson.printJsonFlag(response,flag);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行线索添加操作");
        String id = UUIDUtil.getUUID();
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String customerName = request.getParameter("customerName");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String birth = request.getParameter("birth");
        String mphone = request.getParameter("mphone");
        String source = request.getParameter("source");
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");

        Contacts contacts = new Contacts();
        contacts.setId(id);
        contacts.setFullname(fullname);
        contacts.setAppellation(appellation);
        contacts.setOwner(owner);
        contacts.setJob(job);
        contacts.setEmail(email);
        contacts.setBirth(birth);
        contacts.setMphone(mphone);
        contacts.setSource(source);
        contacts.setCreateBy(createBy);
        contacts.setCreateTime(createTime);
        contacts.setDescription(description);
        contacts.setContactSummary(contactSummary);
        contacts.setNextContactTime(nextContactTime);
        contacts.setAddress(address);

        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.save(contacts,customerName);
        PrintJson.printJsonFlag(response,flag);
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("执行到查询线索信息列表操作");
        String fullname = request.getParameter("fullname");
        String customer = request.getParameter("customer");
        String source = request.getParameter("source");
        String owner = request.getParameter("owner");
        String birth = request.getParameter("birth");
        String pageNoStr =request.getParameter("pageNo");
        String pageSizeStr =request.getParameter("pageSize");

        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        //LIMIT x,y 略过x条，查y条。
        //计算出略过的记录数
        int skipCount = (pageNo - 1) * pageSize;
        //打包
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("fullname",fullname);
        map.put("customer",customer);
        map.put("birth",birth);
        map.put("source",source);
        map.put("owner",owner);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        PageListVO<Contacts> vo = contactsService.pageList(map);
        PrintJson.printJsonObj(response,vo);
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) {
        String[] ids = request.getParameterValues("id");
        ContactsService contactsService = (ContactsService) ServiceFactory.getService(new ContactsServiceImpl());
        boolean flag = contactsService.delete(ids);
        PrintJson.printJsonFlag(response,flag);
    }


}
