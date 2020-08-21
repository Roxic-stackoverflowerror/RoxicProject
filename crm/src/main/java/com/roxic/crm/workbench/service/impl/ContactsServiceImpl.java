package com.roxic.crm.workbench.service.impl;

import com.roxic.crm.settings.dao.UserDao;
import com.roxic.crm.settings.domain.User;
import com.roxic.crm.utils.DateTimeUtil;
import com.roxic.crm.utils.SqlSessionUtil;
import com.roxic.crm.utils.UUIDUtil;
import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.dao.*;
import com.roxic.crm.workbench.domain.*;
import com.roxic.crm.workbench.service.ContactsService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ContactsServiceImpl implements ContactsService {
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    //用户相关
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    @Override
    public List<Contacts> getContactsListByName(Map<String, String> map) {
        List<Contacts> contactsList = contactsDao.getContactsListByName(map);
        return contactsList;
    }

    @Override
    public boolean saveContacts(Contacts contacts) {
        boolean flag = true;
        int count = contactsDao.save(contacts);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean delete(String[] ids) {
        boolean flag = true;

        //查询出需要删除的备注的数量
        int count1 = contactsRemarkDao.getCountsByConids(ids);
        //删除备注，返回受影响的条数
        int count2 = contactsRemarkDao.deleteByConids(ids);
        //查询出需要删除的关系的数量
        int count4 = contactsActivityRelationDao.getCountsByConids(ids);
        //删除市场线索关系内容
        int count5 = contactsActivityRelationDao.deletByConids(ids);
        if(count5 != count4){
            flag = false;
        }

        if(count1 != count2){
            flag = false;
        }

        //删除市场活动
        int count3 = contactsDao.delete(ids);
        if(count3 != ids.length){
            flag = false;
        }
        return flag;
    }

    @Override
    public PageListVO<Contacts> pageList(Map<String, Object> map) {
        //取总条数
        Integer total = contactsDao.getTotalByCondition(map);

        //取得dataList
        List<Contacts> dataList = contactsDao.getContactsListByCondition(map);

        //创建vo，打包
        PageListVO<Contacts> vo = new PageListVO<Contacts> ();
        vo.setTotal(total);
        vo.setDataList(dataList);

        //返回
        return vo;
    }

    @Override
    public boolean save(Contacts contacts,String customerName) {
        boolean flag = true;

        Customer customer = customerDao.getCustomerByName(customerName);

        //如果cus为null，需要创建客户
        if(customer==null){

            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setName(customerName);
            customer.setCreateBy(contacts.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(contacts.getContactSummary());
            customer.setNextContactTime(contacts.getNextContactTime());
            customer.setOwner(contacts.getOwner());
            //添加客户
            int count1 = customerDao.save(customer);
            if(count1!=1){
                flag = false;
            }

        }

        //通过以上对于客户的处理，不论是查询出来已有的客户，还是以前没有我们新增的客户，总之客户已经有了，客户的id就有了
        //将客户id封装到t对象中
        contacts.setCustomerId(customer.getId());

        //添加交易
        int count2 = contactsDao.save(contacts);
        if(count2!=1){
            flag = false;
        }


        return flag;
    }

    @Override
    public boolean update(Contacts contacts) {
        boolean flag = true;
        int count = contactsDao.update(contacts);
        if (count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndContacts(String id) {
        List<User> uList = userDao.getUserList();
        Contacts contacts = contactsDao.getContactsById(id);
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList",uList);
        map.put("contacts",contacts);
        return map;
    }

    @Override
    public Contacts detail(String id) {
        Contacts contacts = contactsDao.detail(id);
        return contacts;
    }

    @Override
    public boolean updateRemark(ContactsRemark conr) {
        boolean flag = true;
        int count = contactsRemarkDao.updateRemark(conr);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public List<ContactsRemark> getRemarkListByConid(String contactsId) {
        List<ContactsRemark> conrList = contactsRemarkDao.getRemarkListByConid(contactsId);
        return conrList;
    }

    @Override
    public boolean removeRemark(String id) {
        boolean flag = true;

        int count = contactsRemarkDao.removeRemark(id);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean saveRemark(ContactsRemark conr) {
        boolean flag = true;
        int count = contactsRemarkDao.saveRemark(conr);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean bound(String contactsId, String[] activityIds) {
        boolean flag = true;
        for(String activityId : activityIds){
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setActivityId(activityId);
            contactsActivityRelation.setContactsId(contactsId);

            int count = contactsActivityRelationDao.bound(contactsActivityRelation);

            if(count != 1){
                flag = false;
            }
        }
        return flag;
    }

    @Override
    public boolean unbound(String id) {
        boolean flag = true;
        int count = contactsActivityRelationDao.unbound(id);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public List<Tran> getTranListByConid(String id) {
        List<Tran> tranList = tranDao.getTranListByConid(id);
        return tranList;
    }

}
