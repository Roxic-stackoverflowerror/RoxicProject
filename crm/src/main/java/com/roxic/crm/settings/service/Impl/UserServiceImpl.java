package com.roxic.crm.settings.service.Impl;

import com.roxic.crm.exception.LoginException;
import com.roxic.crm.settings.dao.UserDao;
import com.roxic.crm.settings.domain.User;
import com.roxic.crm.settings.service.UserService;
import com.roxic.crm.utils.DateTimeUtil;
import com.roxic.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserServiceImpl implements UserService{
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    public User login(String loginAct, String loginPwd, String ip) throws LoginException {
        Map<String,String> map = new HashMap<String, String>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);

        User user = userDao.login(map);

        if(user == null){
            throw new LoginException("账号密码不正确!");
        }

        //如果程序能够成功执行到该行，说明账号密码正确
        //继续向下验证剩下的信息

        //验证失效时间
        String expireTime = user.getExpireTime();
        String currentTime = DateTimeUtil.getSysTime();
        if(expireTime.compareTo(currentTime)<0){
            throw new LoginException("账号密码已失效!");
        }

        //判断锁定状态
        String lockState = user.getLockState();
        if("0".equals(lockState)){
            throw new LoginException("账号已被锁定!");
        }

        //判断ip地址
        String allowIps = user.getAllowIps();
        if(allowIps.contains(ip)){
            throw new LoginException("ip地址受限");
        }

        return user;

    }

    public List<User> getUserList() {
        List<User> userList = userDao.getUserList();
        return userList;
    }
}
