---
title: MikroORM multirange (PostgreSQL) Custom Type
date: 2024-03-18 08:47:37
tags:
---

```
import { Type } from '@mikro-orm/core';
import dayjs from 'dayjs';

/**
 * Тип PostgreSQL 14+ tsmultirange
 * @example tsmultirange.convertToJSValue('{["2024-01-01 00:00:00","2024-01-01 18:00:00"),["2024-01-01 19:00:00","2024-01-01 23:00:00")}');
 * @example tsmultirange.convertToDatabaseValue([[1704056400000, 1704121200000], [1704124800000, 1704139200000]]);
 */
export class TsMultirange extends Type<[number, number][], string> {
  /**
   * Конвертировать значение в соответствующее представление tsmultirange в PostgreSQL
   * @param jsRanges Диапазоны в формате [timestampFrom, timestampTo][]
   * @returns Строчное представление данных в PostgreSQL
   */
  convertToDatabaseValue(jsRanges: [number, number][]): string {
    const ranges: string[] = [];
    const dateFormat = 'YYYY-MM-DD HH:mm';
    for (const [from, to] of jsRanges) {
      ranges.push(`[${dayjs(from).format(dateFormat)}, ${dayjs(to).format(dateFormat)})`);
    };
    const result = `{${ranges.join(',')}}`;
    return result;
  };

  /**
   * Конвертировать значение, представленное в виде строки в PostgreSQL в соответствующий объект
   * @param dbValue Диапазон в формате tsmultirange в PostgreSQL
   * @returns Диапазоны в формате [timestampFrom, timestampTo][]
   */
  convertToJSValue(dbValue: string): [number, number][] {
    const rangesRegExp = /\[(.*?[^\\])\)/g;
    const matches: IterableIterator<RegExpMatchArray> = dbValue.matchAll(rangesRegExp);
    const result = [];
    for (const match of matches) {
      const jsRange = match[1]
        .replace(/"/g, '')
        .split(',')
        .map((datetime: string) => dayjs(datetime).valueOf());
      result.push(jsRange);
    }
    return result;
  };

  /**
   * Тип столбца в PostgreSQL
   * @returns Тип столбца
   */
  getColumnType(): string {
    return 'tsmultirange';
  }
}
```
