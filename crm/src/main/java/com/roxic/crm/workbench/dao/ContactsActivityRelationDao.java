package com.roxic.crm.workbench.dao;

import com.roxic.crm.workbench.domain.ContactsActivityRelation;

public interface ContactsActivityRelationDao {

    int save(ContactsActivityRelation contactsActivityRelation);

    int getCountsByConids(String[] ids);

    int deletByConids(String[] ids);

    int unbound(String id);

    int bound(ContactsActivityRelation contactsActivityRelation);
}
