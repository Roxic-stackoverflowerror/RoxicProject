package com.roxic.crm.settings.service.Impl;

import com.roxic.crm.settings.dao.DicTypeDao;
import com.roxic.crm.settings.dao.DicValueDao;
import com.roxic.crm.settings.domain.DicType;
import com.roxic.crm.settings.domain.DicValue;
import com.roxic.crm.settings.service.DicService;
import com.roxic.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImpl  implements DicService {
    private DicTypeDao dicTypeDao = SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dicValueDao = SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    @Override
    public Map<String, List<DicValue>> getAll() {
        Map<String, List<DicValue>> map = new HashMap<String, List<DicValue>>();
        //将字典类型都拿出来
        List<DicType> dicTypeList = dicTypeDao.getTypeList();
        //将字典类型列表遍历出来，根据类型取value
        for(DicType dicType : dicTypeList){
            String typeCode = dicType.getCode();
            //根据字典类型取得列表
            List<DicValue> dicValueList = dicValueDao.getListByTypeCode(typeCode);
            map.put(typeCode,dicValueList);
        }
        return map;
    }
}
