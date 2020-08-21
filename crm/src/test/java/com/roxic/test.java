package com.roxic;

import com.roxic.crm.utils.DateTimeUtil;
import com.roxic.crm.utils.MD5Util;

import java.util.UUID;

public class test {
    public static void main(String[] args) {
        System.out.println(UUID.randomUUID().toString());
        System.out.println(MD5Util.getMD5("110088ff"));
        System.out.println(DateTimeUtil.getSysTime());
    }
}
