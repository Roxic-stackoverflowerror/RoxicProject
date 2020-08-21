package com.roxic.crm.settings.dao;

import com.roxic.crm.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {
    List<DicValue> getListByTypeCode(String typeCode);
}
