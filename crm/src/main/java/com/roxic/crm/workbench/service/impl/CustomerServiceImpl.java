package com.roxic.crm.workbench.service.impl;

import com.roxic.crm.settings.dao.UserDao;
import com.roxic.crm.settings.domain.User;
import com.roxic.crm.utils.SqlSessionUtil;
import com.roxic.crm.vo.PageListVO;
import com.roxic.crm.workbench.dao.ContactsDao;
import com.roxic.crm.workbench.dao.CustomerDao;
import com.roxic.crm.workbench.dao.CustomerRemarkDao;
import com.roxic.crm.workbench.dao.TranDao;
import com.roxic.crm.workbench.domain.Contacts;
import com.roxic.crm.workbench.domain.Customer;
import com.roxic.crm.workbench.domain.CustomerRemark;
import com.roxic.crm.workbench.domain.Tran;
import com.roxic.crm.workbench.service.CustomerService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CustomerServiceImpl implements CustomerService {
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);
    //用户相关
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);

    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);

    @Override
    public List<String> getCustomerName(String name) {
        List<String> sList = customerDao.getCustomerName(name);
        return sList;
    }

    @Override
    public PageListVO<Customer> pageList(Map<String, Object> map) {
        //取总条数
        Integer total = customerDao.getTotalByCondition(map);

        //取得dataList
        List<Customer> dataList = customerDao.getCustomerListByCondition(map);

        //创建vo，打包
        PageListVO<Customer> vo = new PageListVO<Customer> ();
        vo.setTotal(total);
        vo.setDataList(dataList);

        //返回
        return vo;
    }

    @Override
    public boolean save(Customer customer) {
        boolean flag = true;
        int count = customerDao.save(customer);
        if (count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean update(Customer customer) {
        boolean flag = true;
        int count = customerDao.update(customer);
        if (count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public Map<String, Object> getUserListAndCustomer(String id) {
        List<User> uList = userDao.getUserList();
        Customer customer = customerDao.getCustomerById(id);
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("uList",uList);
        map.put("customer",customer);
        return map;
    }

    @Override
    public boolean delete(String[] ids) {
        boolean flag = true;

        //查询出需要删除的备注的数量
        int count1 = customerRemarkDao.getCountsByCuids(ids);
        //删除备注，返回受影响的条数
        int count2 = customerRemarkDao.deleteByCuids(ids);

        if(count1 != count2){
            flag = false;
        }
        //删除市场活动
        int count3 = customerDao.delete(ids);
        if(count3 != ids.length){
            flag = false;
        }
        return flag;
    }

    @Override
    public Customer detail(String id) {
        Customer customer = customerDao.detail(id);
        return customer;
    }

    @Override
    public boolean updateRemark(CustomerRemark cur) {
        boolean flag = true;
        int count = customerRemarkDao.updateRemark(cur);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public List<CustomerRemark> getRemarkListByCuid(String customerId) {
        List<CustomerRemark> curList = customerRemarkDao.getRemarkListByCuid(customerId);
        return curList;
    }

    @Override
    public boolean removeRemark(String id) {
        boolean flag = true;

        int count = customerRemarkDao.removeRemark(id);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public boolean saveRemark(CustomerRemark cur) {
        boolean flag = true;
        int count = customerRemarkDao.saveRemark(cur);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    @Override
    public List<Tran> getTranListByCuid(String id) {
        List<Tran> tranList = tranDao.getTranListByCuid(id);
        return tranList;
    }

    @Override
    public List<Contacts> getContactsListByCuid(String id) {
        List<Contacts> contactsList =  contactsDao.getContactsListByCuid(id);
        return contactsList;
    }
}
