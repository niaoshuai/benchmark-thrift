package com.didiglobal.pressir.thrift.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.util.TypeUtils;
import org.apache.logging.log4j.util.Strings;

import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.math.BigInteger;

/**
 * @ClassName ReflectUtils
 * @Description 工具类
 * @Author pressir
 * @Date 2019-09-03 11:32
 */
public class ReflectUtils {

    public static Class<?> findInnerClass(Class<?> clazz, String name) throws ClassNotFoundException {
        Class<?>[] innerClasses = clazz.getClasses();
        for (Class innerClass : innerClasses) {
            if (innerClass.getSimpleName().equals(name)) {
                return innerClass;
            }
        }
        throw new ClassNotFoundException("inner class(" + clazz.getName() + '$' + name + ") is invalid");
    }

    public static Method findMethod(Class<?> clazz, String name) throws NoSuchMethodException {
        Method[] methods = clazz.getMethods();
        for (Method method : methods) {
            if (method.getName().equals(name)) {
                return method;
            }
        }
        throw new NoSuchMethodException("method(" + clazz.getName() + '.' + name + ") is invalid");
    }

    public static Object[] castArgs(Method method, String... args) {
        int parameterCount = method.getParameterCount();
        if (method.getParameterCount() == 0) {
            if (args == null || args.length == 0) {
                return new Object[0];
            }
            throw new IllegalArgumentException("invalid args. expect 0 parameters, " +
                    "actual got " + args.length);
        }
        if (args == null) {
            throw new IllegalArgumentException("invalid args. expect " + parameterCount + " parameters, " +
                    "actual got 0");
        }
        if (args.length < parameterCount) {
            throw new IllegalArgumentException("invalid args. expect " + parameterCount + " parameters, " +
                    "actual got " + args.length);
        }
        if (args.length > parameterCount) {
            for (int i = parameterCount; i < args.length; i++) {
                if (Strings.isNotBlank(args[i])) {
                    throw new IllegalArgumentException("invalid args. expect " + parameterCount + " parameters, " +
                            "actual got " + args.length);
                }
            }
        }
        Object[] arguments = new Object[parameterCount];
        Type[] parameterTypes = method.getGenericParameterTypes();
        for (int i = 0; i < parameterCount; i++) {
            arguments[i] = cast(args[i], parameterTypes[i]);
        }
        return arguments;
    }

    public static <T> T cast(Object obj, Type type) {
        if (obj == null) {
            return null;
        }
        if (type == String.class) {
            return (T) obj.toString();
        }
        if (type == byte.class || type == Byte.class) {
            return (T) TypeUtils.castToByte(obj);
        }
        if (type == short.class || type == Short.class) {
            return (T) TypeUtils.castToShort(obj);
        }
        if (type == int.class || type == Integer.class) {
            return (T) TypeUtils.castToInt(obj);
        }
        if (type == long.class || type == Long.class) {
            return (T) TypeUtils.castToLong(obj);
        }
        if (type == float.class || type == Float.class) {
            return (T) TypeUtils.castToFloat(obj);
        }
        if (type == double.class || type == Double.class) {
            return (T) TypeUtils.castToDouble(obj);
        }
        if (type == char.class || type == Character.class) {
            return (T) TypeUtils.castToChar(obj);
        }
        if (type == boolean.class || type == Boolean.class) {
            return (T) TypeUtils.castToBoolean(obj);
        }
        if (type == BigDecimal.class) {
            return (T) TypeUtils.castToBigDecimal(obj);
        }
        if (type == BigInteger.class) {
            return (T) TypeUtils.castToBigInteger(obj);
        }
        return JSON.parseObject(obj.toString(), type);
    }
}
