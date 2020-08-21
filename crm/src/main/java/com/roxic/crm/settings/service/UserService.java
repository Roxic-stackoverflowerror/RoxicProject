package com.roxic.crm.settings.service;

import com.roxic.crm.exception.LoginException;
import com.roxic.crm.settings.domain.User;

import java.util.List;

public interface UserService {
    User login(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> getUserList();
}
