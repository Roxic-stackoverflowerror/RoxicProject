package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsDao {

    int save(Contacts contacts);

    List<Contacts> getContactsListByName(Map<String, String> map);

    List<Contacts> getContactsListByCuid(String id);

    int delete(String[] id);

    List<Contacts> getContactsListByCondition(Map<String, Object> map);

    Integer getTotalByCondition(Map<String, Object> map);

    int update(Contacts contacts);

    Contacts getContactsById(String id);

    Contacts detail(String id);
}
