#  Java-获取当前时间的时间戳

获取当前时间戳的方法有很多种，可以根据你的需求和使用的Java版本来选择适合的方法。以下是五种获取当前时间戳的方法：

## 方法1：使用`System.currentTimeMillis()`

```java
long currentTimeMillis = System.currentTimeMillis();
```

## 方法2：使用`java.util.Date`

```java
Date currentDate = new Date();
long timestamp = currentDate.getTime();
```

## 方法3：使用`java.time.Instant`

```java
Instant currentInstant = Instant.now();
long timestamp = currentInstant.toEpochMilli();
```

## 方法4：使用`java.time.LocalDateTime和java.time.ZoneId`

```java
LocalDateTime localDateTime = LocalDateTime.now();
ZoneId zoneId = ZoneId.systemDefault();
ZonedDateTime zonedDateTime = ZonedDateTime.of(localDateTime, zoneId);
long currentTimestamp = zonedDateTime.toInstant().toEpochMilli();
```

## 方法5：使用`java.sql.Timestamp`

```java
Timestamp currentTimestamp = new Timestamp(System.currentTimeMillis());
long timestamp = currentTimestamp.getTime();
```

根据你的具体需求，选择其中一种方法即可获取当前时间的时间戳。

最常用的是方法1 `System.currentTimeMillis()`

