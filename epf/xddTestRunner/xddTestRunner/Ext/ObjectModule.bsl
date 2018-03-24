﻿
Процедура Инициализация()
	
	ЭтоВстроеннаяОбработка = ОбработкаЯвляетсяВстроеннойВКонфигурацию();
	Если ЭтоВстроеннаяОбработка Тогда
		// Для встроенной в состав конфигурации обработки
		// может быть использван префикс, который определяет имена объектов
		// фреймворка xUnitFor1C в составе конфигурации
		// Например: Обработки.<префикс>xddTestRunner
		// Если префикс не задан, то должны использоваться оригинальные 
		// имена обработок и подсистем.
		// Для подсистем нужно добавлять префикс тольяо для главной - "xUnitFor1C" 
		ИспользуемыйПрефиксПодсистемы = "";
	Иначе
		ПолныйПутьКФайлуБраузераТестов = ЭтотОбъект["ИспользуемоеИмяФайла"];
	КонецЕсли;
	ПолноеИмяБраузераТестов = Метаданные().ПолноеИмя();
	
	ТипыПлагинов = ТипыПлагинов();
	СостоянияТестов = СостоянияТестов();
	СтатусыРезультатаТестирования = СтатусыРезультатаТестирования();
	ВозможныеСобытия = ВозможныеСобытия();
	ВозможныеИсключения = ВозможныеИсключения();
	
	ЗагрузитьНастройки();
КонецПроцедуры

Функция Версия() Экспорт
	Версия = "5.0.0.124";
	Возврат Версия;
КонецФункции

Функция ЗаголовокФормы() Экспорт
	Возврат СокрЛП(Метаданные().Синоним) + ", версия " + Версия();
КонецФункции

// { Plugins
Функция ТипыПлагинов()
	Результат = Новый Структура;
	Результат.Вставить("Загрузчик", "Загрузчик");
	Результат.Вставить("Утилита", "Утилита");
	Результат.Вставить("ГенераторОтчета", "ГенераторОтчета");
	
	Возврат Новый ФиксированнаяСтруктура(Результат);
КонецФункции

Функция Плагин(Знач Идентификатор) Экспорт
	
	ИдентификаторПлагинаСПрефиксомПодсистемы = ДополнитьИдентификаторПрефиксомПодсистемы(Идентификатор);
	ИдентификаторПлагинаБезПрефиксаПодсистемы = ПолучитьИдентификаторБезПрефиксаПодсистемы(Идентификатор);
	Плагин = Плагины[ИдентификаторПлагинаБезПрефиксаПодсистемы];
	Если ТипЗнч(Плагин) = Тип("Строка") Тогда
		Плагин = СоздатьОбъектПлагина(Плагин);
	КонецЕсли;
	
	Возврат Плагин;
	
КонецФункции

Функция ПолучитьОписанияПлагиновПоТипу(Знач ТипПлагина) Экспорт
	Результат = Новый Массив;
	Для каждого КлючЗначение Из Плагины Цикл
		Плагин = Плагин(КлючЗначение.Ключ);
		Плагин.Инициализация(ЭтотОбъект);
		ОписаниеПлагина = Плагин.ОписаниеПлагина(ТипыПлагинов);
		Если ОписаниеПлагина.Тип = ТипПлагина Тогда
			Результат.Добавить(ОписаниеПлагина);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция ЗагрузчикПоУмолчанию() Экспорт
	Возврат Плагин("ЗагрузчикКаталога");
КонецФункции
// } Plugins

// { Выполнение тестов
Функция ПолучитьКоличествоТестовыхМетодов(Знач КонтейнерДереваТестов, Знач Фильтр = Неопределено) Экспорт
	КоличествоТестовыхМетодов = 0;
	ФильтрДляДочернихУзлов = Неопределено;
	Если Не УзелДереваТестовУдовлетворяетФильтру(КонтейнерДереваТестов, Фильтр) Тогда
		ФильтрДляДочернихУзлов = Фильтр;
	КонецЕсли;
	Для каждого ДочернийУзел Из КонтейнерДереваТестов.Строки Цикл
		КоличествоДочернихТестовыхМетодов = 0;
		Если ДочернийУзел.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Контейнер Тогда
			КоличествоДочернихТестовыхМетодов = ПолучитьКоличествоТестовыхМетодов(ДочернийУзел, ФильтрДляДочернихУзлов);
		ИначеЕсли ДочернийУзел.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Элемент Тогда
			Если УзелДереваТестовУдовлетворяетФильтру(ДочернийУзел, ФильтрДляДочернихУзлов) Тогда
				КоличествоДочернихТестовыхМетодов = 1;
			КонецЕсли;
		КонецЕсли;
		КоличествоТестовыхМетодов = КоличествоТестовыхМетодов + КоличествоДочернихТестовыхМетодов;
	КонецЦикла;
	
	Возврат КоличествоТестовыхМетодов;
КонецФункции

Функция ВыполнитьТесты(Знач Загрузчик, Знач КонтейнерДереваТестов, Знач Фильтр = Неопределено, Знач Подписчик = Неопределено) Экспорт
	РезультатТестирования = СоздатьКонтейнерРезультатовТестирования(КонтейнерДереваТестов);
	ФильтрДляДочернихУзлов = Неопределено;
	Если Не УзелДереваТестовУдовлетворяетФильтру(КонтейнерДереваТестов, Фильтр) Тогда
		ФильтрДляДочернихУзлов = Фильтр;
	КонецЕсли;
	
	ПутьИзКонтейнера = КонтейнерДереваТестов.Путь;
	Если ПутьИзКонтейнера <> "" Тогда
		КонтекстВыполненияДляКонтейнера = Загрузчик.ПолучитьКонтекстПоПути(ЭтотОбъект, ПутьИзКонтейнера);
	КонецЕсли;
	
	Если КонтейнерДереваТестов.СлучайныйПорядокВыполнения Тогда
		СтрокиКонтейнера = ПеремешатьМассив(КонтейнерДереваТестов.Строки);
	Иначе
		СтрокиКонтейнера = КонтейнерДереваТестов.Строки;
	КонецЕсли;
	
	Для каждого ДочернийУзел Из СтрокиКонтейнера Цикл
		ДочернийРезультатТестирования = Неопределено;
		Если ДочернийУзел.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Контейнер Тогда
			ДочернийРезультатТестирования = ВыполнитьТесты(Загрузчик, ДочернийУзел, ФильтрДляДочернихУзлов, Подписчик);
		ИначеЕсли ДочернийУзел.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Элемент Тогда
			Если УзелДереваТестовУдовлетворяетФильтру(ДочернийУзел, ФильтрДляДочернихУзлов) Тогда
				Если ПутьИзКонтейнера = ДочернийУзел.Путь Тогда
					Контекст = КонтекстВыполненияДляКонтейнера;
				Иначе
					Контекст = Загрузчик.ПолучитьКонтекстПоПути(ЭтотОбъект, ДочернийУзел.Путь);
					// Заполняем служебные поля, если они имеются
					ЗаполнитьСвойствоПриНаличии(Контекст, "ПутьКФайлуПолный", ДочернийУзел.Путь);
				КонецЕсли;
				ЭтотОбъект.ТекущийКонтейнер = КонтейнерДереваТестов;
				ДочернийРезультатТестирования = ВыполнитьТестовыйМетод(Контекст, ДочернийУзел);
				
				Если Подписчик <> Неопределено Тогда
					ОповеститьОСобытии(Подписчик, ЭтотОбъект.ВозможныеСобытия.ВыполненТестовыйМетод, ДочернийРезультатТестирования);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если ДочернийРезультатТестирования <> Неопределено Тогда
			РезультатТестирования.Строки.Добавить(ДочернийРезультатТестирования);
			РезультатТестирования.Состояние = ВыбратьХудшееСостояниеВыполненияТестов(РезультатТестирования.Состояние, ДочернийРезультатТестирования.Состояние);
			ЗаполнитьДанныеСтатистики(РезультатТестирования, ДочернийРезультатТестирования);
			
			Если Не КонтейнерДереваТестов.СлучайныйПорядокВыполнения И ДочернийРезультатТестирования.Состояние <> ЭтотОбъект.СостоянияТестов.Пройден Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Если РезультатТестирования.Строки.Количество() = 0 Тогда
		РезультатТестирования = Неопределено;
	Иначе
			
		Если Не КонтейнерДереваТестов.СлучайныйПорядокВыполнения И ПутьИзКонтейнера <> "" И РезультатТестирования.Состояние <> ЭтотОбъект.СостоянияТестов.Пройден Тогда
			ЭлементДеструктор = КонтейнерДереваТестов.ЭлементДеструктор;
			
			Если ЭлементДеструктор <> Неопределено И Строка(ДочернийРезультатТестирования.Ключ) <> Строка(ЭлементДеструктор.Ключ) Тогда
				
				НовыйДочернийРезультатТестирования = СоздатьЭлементРезультатовТестирования(ЭлементДеструктор);
				НовыйДочернийРезультатТестирования.Состояние = СостоянияТестов.Пройден;
				
				Попытка
					ВыполнитьНеобязательнуюПроцедуруТестовогоСлучая(КонтекстВыполненияДляКонтейнера, ЭлементДеструктор.ИмяМетода);
				Исключение
					ИнформацияОбОшибке = ИнформацияОбОшибке();
					ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
					НовыйДочернийРезультатТестирования.Сообщение = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
					
					Если ЭтоОшибкаПроверки(ТекстОшибки) Тогда
						НовыйДочернийРезультатТестирования.Состояние = СостоянияТестов.Сломан;
					Иначе
						НовыйДочернийРезультатТестирования.Состояние = СостоянияТестов.НеизвестнаяОшибка;
					КонецЕсли;
				КонецПопытки;
				
				РезультатТестирования.Строки.Добавить(НовыйДочернийРезультатТестирования);
				РезультатТестирования.Состояние = ВыбратьХудшееСостояниеВыполненияТестов(РезультатТестирования.Состояние, ДочернийРезультатТестирования.Состояние);
				ЗаполнитьДанныеСтатистики(РезультатТестирования, ДочернийРезультатТестирования);
			КонецЕсли;
			
		КонецЕсли;
	КонецЕсли;
	
	Возврат РезультатТестирования;
КонецФункции

Функция УзелДереваТестовУдовлетворяетФильтру(Знач УзелДереваТестов, Знач Фильтр)
	Возврат (Фильтр = Неопределено) Или (Фильтр.Найти(УзелДереваТестов.Ключ) <> Неопределено);
КонецФункции

Процедура ЗаполнитьДанныеСтатистики(РезультатТестирования, Знач ДочернийРезультатТестирования) Экспорт
	Если ДочернийРезультатТестирования.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Контейнер Тогда
		РезультатТестирования.КоличествоТестов = РезультатТестирования.КоличествоТестов + ДочернийРезультатТестирования.КоличествоТестов;
		РезультатТестирования.КоличествоСломанныхТестов = РезультатТестирования.КоличествоСломанныхТестов + ДочернийРезультатТестирования.КоличествоСломанныхТестов;
		РезультатТестирования.КоличествоНеРеализованныхТестов = РезультатТестирования.КоличествоНеРеализованныхТестов + ДочернийРезультатТестирования.КоличествоНеРеализованныхТестов;
		РезультатТестирования.КоличествоОшибочныхТестов = РезультатТестирования.КоличествоОшибочныхТестов + ДочернийРезультатТестирования.КоличествоОшибочныхТестов;
		
	ИначеЕсли ДочернийРезультатТестирования.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Элемент Тогда
		РезультатТестирования.КоличествоТестов = РезультатТестирования.КоличествоТестов + 1;
		Если ДочернийРезультатТестирования.Состояние = СостоянияТестов.Сломан Тогда
			РезультатТестирования.КоличествоСломанныхТестов = РезультатТестирования.КоличествоСломанныхТестов + 1;
		ИначеЕсли ДочернийРезультатТестирования.Состояние = СостоянияТестов.НеРеализован Тогда
			РезультатТестирования.КоличествоНеРеализованныхТестов = РезультатТестирования.КоличествоНеРеализованныхТестов + 1;
		ИначеЕсли ДочернийРезультатТестирования.Состояние = СостоянияТестов.НеизвестнаяОшибка Тогда
			РезультатТестирования.КоличествоОшибочныхТестов = РезультатТестирования.КоличествоОшибочныхТестов + 1;
		КонецЕсли;
	КонецЕсли;
	РезультатТестирования.ВремяВыполнения = РезультатТестирования.ВремяВыполнения + ДочернийРезультатТестирования.ВремяВыполнения;
КонецПроцедуры

Функция ВыбратьХудшееСостояниеВыполненияТестов(Знач Состояние1, Знач Состояние2)
	Возврат Макс(Состояние1, Состояние2);
КонецФункции

Функция ВыполнитьТестовыйМетод(Знач КонтекстВыполнения, Знач ЭлементДереваТестов) Экспорт
	РезультатТестирования = СоздатьЭлементРезультатовТестирования(ЭлементДереваТестов);
	НачалоВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Если ВыполнитьИнициализациюКонтекста(КонтекстВыполнения, РезультатТестирования) Тогда
	
		Попытка
			ВыполнитьНеобязательнуюПроцедуруТестовогоСлучая(КонтекстВыполнения, ЭлементДереваТестов.ПередЗапускомТеста);
			ВыполнитьПроцедуруКонтекста(КонтекстВыполнения, ЭлементДереваТестов.ИмяМетода, ЭлементДереваТестов.Параметры);
			
			РезультатТестирования.Состояние = СостоянияТестов.Пройден;
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
			КраткийТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
			Если ЕстьОшибка_МетодОбъектаНеОбнаружен(КраткийТекстОшибки, ЭлементДереваТестов.ИмяМетода) Тогда
				РезультатТестирования.Состояние = СостоянияТестов.НеРеализован;
				Сообщение = НСтр("ru = 'Отсутствует реализация тестового метода (%1).'");
				РезультатТестирования.Сообщение = СтрЗаменить(Сообщение, "%1", ЭлементДереваТестов.ИмяМетода);
			Иначе
				РезультатТестирования.Сообщение = ТекстОшибки;
				Если ЭтоОшибкаПроверки(КраткийТекстОшибки) Тогда
					РезультатТестирования.Состояние = СостоянияТестов.Сломан;
				ИначеЕсли ЭтоПропущенныйТест(КраткийТекстОшибки) Тогда
					РезультатТестирования.Состояние = СостоянияТестов.НеРеализован;
				Иначе
					РезультатТестирования.Состояние = СостоянияТестов.НеизвестнаяОшибка;
				КонецЕсли;
			КонецЕсли;
		КонецПопытки;
		Попытка
			ВыполнитьНеобязательнуюПроцедуруТестовогоСлучая(КонтекстВыполнения, ЭлементДереваТестов.ПослеЗапускаТеста);
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
			КраткийТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
			
			РезультатТестирования.Сообщение = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке);
			
			Если ЭтоОшибкаПроверки(ТекстОшибки) Тогда
				РезультатТестирования.Состояние = СостоянияТестов.Сломан;
			Иначе
				РезультатТестирования.Состояние = СостоянияТестов.НеизвестнаяОшибка;
			КонецЕсли;
		КонецПопытки;
	КонецЕсли;
	
	ОкончаниеВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();
	РезультатТестирования.ВремяВыполнения = (ОкончаниеВыполнения - НачалоВыполнения) / 1000;
	РезультатТестирования.ВремяНачала = НачалоВыполнения;
	РезультатТестирования.ВремяОкончания = ОкончаниеВыполнения;
	
	Возврат РезультатТестирования;
КонецФункции

Функция ВыполнитьИнициализациюКонтекста(КонтекстВыполнения, РезультатТестирования)
	Попытка
		КонтекстВыполнения.Инициализация(ЭтотОбъект);
		Возврат Истина;
	Исключение
		РезультатТестирования.Сообщение = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		РезультатТестирования.Состояние = СостоянияТестов.НеизвестнаяОшибка;
	КонецПопытки;
	Возврат Ложь;
КонецФункции

Процедура ВыполнитьНеобязательнуюПроцедуруТестовогоСлучая(Знач КонтекстВыполнения, Знач ИмяПроцедуры)
	Попытка
		ВыполнитьПроцедуруКонтекста(КонтекстВыполнения, ИмяПроцедуры);
	Исключение
		ТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Если Не ЕстьОшибка_МетодОбъектаНеОбнаружен(ТекстОшибки, ИмяПроцедуры) Тогда
			ВызватьИсключение;
		КонецЕсли;
	КонецПопытки;
КонецПроцедуры

Процедура ВыполнитьПроцедуруКонтекста(Знач КонтекстВыполнения, Знач ПроцедураКонтекста, Знач Параметры = Неопределено)
	СтрокаПараметров = СформироватьСтрокуПараметров(Параметры);
	ИcполняемыйКод = "КонтекстВыполнения." + ПроцедураКонтекста + "(" + СтрокаПараметров + ");";
	Выполнить(ИcполняемыйКод);
КонецПроцедуры

Функция СформироватьСтрокуПараметров(Знач Параметры)
	СтрокаПараметров = "";
	Если ТипЗнч(Параметры) = Тип("Массив") Тогда
		Для Сч = 0 По Параметры.Количество() - 1 Цикл
			СтрокаПараметров = СтрокаПараметров + ",Параметры[" + Формат(Сч, "ЧН=0; ЧГ=") + "]";
		КонецЦикла;
	КонецЕсли;
	
	Возврат Сред(СтрокаПараметров, 2);
КонецФункции

Функция ЕстьОшибка_МетодОбъектаНеОбнаружен(Знач ТекстОшибки, Знач ИмяМетода)
	Результат = Ложь;
	Если Найти(текстОшибки, "Метод объекта не обнаружен (" + ИмяМетода + ")") > 0 
		ИЛИ Найти(текстОшибки, "Object method not found (" + ИмяМетода + ")") > 0  Тогда
		Результат = Истина;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Функция ЭтоОшибкаПроверки(ТекстОшибки)
	
	Возврат Найти(ТекстОшибки, "["+ СтатусыРезультатаТестирования.ОшибкаПроверки + "]") = 1;
	
КонецФункции

Функция ЭтоПропущенныйТест(ТекстОшибки)
	
	Возврат Найти(ТекстОшибки, "["+ СтатусыРезультатаТестирования.ТестПропущен + "]") > 0;
	
КонецФункции

// } Выполнение тестов

// { Генерация результатов тестирования
Функция СостоянияТестов()
	СостоянияТестов = Новый Структура;
	СостоянияТестов.Вставить("НеВыполнен", 0);
	СостоянияТестов.Вставить("Пройден", 1);
	СостоянияТестов.Вставить("НеРеализован", 2);
	СостоянияТестов.Вставить("Сломан", 3);
	СостоянияТестов.Вставить("НеизвестнаяОшибка", 4);
	
	Возврат Новый ФиксированнаяСтруктура(СостоянияТестов);
КонецФункции

Функция СтатусыРезультатаТестирования()
	СтатусыРезультатаТестирования = Новый Структура;
	СтатусыРезультатаТестирования.Вставить("ОшибкаПроверки", "Failed");
	СтатусыРезультатаТестирования.Вставить("НеизвестнаяОшибка", "Broken");
	СтатусыРезультатаТестирования.Вставить("ТестПропущен", "Pending");
	
	Возврат Новый ФиксированнаяСтруктура(СтатусыРезультатаТестирования);
КонецФункции

Функция СоздатьКонтейнерРезультатовТестирования(Знач КонтейнерДереваТестов)
	ГруппаРезультатовТестирования = Новый Структура;
	ГруппаРезультатовТестирования.Вставить("Ключ", КонтейнерДереваТестов.Ключ);
	ГруппаРезультатовТестирования.Вставить("Тип", КонтейнерДереваТестов.Тип);
	ГруппаРезультатовТестирования.Вставить("Имя", КонтейнерДереваТестов.Имя);
	ГруппаРезультатовТестирования.Вставить("ИконкаУзла", КонтейнерДереваТестов.ИконкаУзла);
	ГруппаРезультатовТестирования.Вставить("Состояние", СостоянияТестов.НеВыполнен);
	ГруппаРезультатовТестирования.Вставить("КоличествоТестов", 0);
	ГруппаРезультатовТестирования.Вставить("КоличествоСломанныхТестов", 0);
	ГруппаРезультатовТестирования.Вставить("КоличествоНеРеализованныхТестов", 0);
	ГруппаРезультатовТестирования.Вставить("КоличествоОшибочныхТестов", 0);
	ГруппаРезультатовТестирования.Вставить("ВремяВыполнения", 0);
	ГруппаРезультатовТестирования.Вставить("Сообщение", "");
	ГруппаРезультатовТестирования.Вставить("Строки", Новый Массив);
	
	Возврат ГруппаРезультатовТестирования;
КонецФункции

Функция СоздатьЭлементРезультатовТестирования(Знач ЭлементДереваТестов)
	РезультатТестирования = Новый Структура;
	РезультатТестирования.Вставить("Ключ", ЭлементДереваТестов.Ключ);
	РезультатТестирования.Вставить("Тип", ЭлементДереваТестов.Тип);
	РезультатТестирования.Вставить("Путь", ЭлементДереваТестов.Путь);
	РезультатТестирования.Вставить("ИмяМетода", ЭлементДереваТестов.ИмяМетода);
	РезультатТестирования.Вставить("Представление", ЭлементДереваТестов.Представление);
	РезультатТестирования.Вставить("Параметры", ЭлементДереваТестов.Параметры);
	РезультатТестирования.Вставить("Состояние", СостоянияТестов.НеВыполнен);
	РезультатТестирования.Вставить("ВремяВыполнения", 0);
	РезультатТестирования.Вставить("ВремяНачала", 0);
	РезультатТестирования.Вставить("ВремяОкончания", 0);
	РезультатТестирования.Вставить("Сообщение", "");
	
	Возврат РезультатТестирования;
КонецФункции
// } Генерация результатов тестирования

// { Настройки браузера тестирования
Процедура ЗагрузитьНастройки() Экспорт
	ЭтотОбъект.Настройки = ПолучитьПустыеНастройкиБраузераТестирования();
	// Ключом настроек должно быть не имя обработки, а полное имя метаданных, т.к. имя внешней обработки
	// может совпадать с именем обработки, встроенной в состав конфигурации
	СчитанныеНастройки = ХранилищеОбщихНастроек.Загрузить(ЭтотОбъект.Метаданные().ПолноеИмя());
	Если ТипЗнч(СчитанныеНастройки) = Тип("Структура") Тогда
		Для каждого СчитанныеКлючЗначение Из СчитанныеНастройки Цикл
			Если ЭтотОбъект.Настройки.Свойство(СчитанныеКлючЗначение.Ключ) И ТипЗнч(СчитанныеКлючЗначение.Значение) = ТипЗнч(ЭтотОбъект.Настройки[СчитанныеКлючЗначение.Ключ]) Тогда
				ЭтотОбъект.Настройки[СчитанныеКлючЗначение.Ключ] = СчитанныеКлючЗначение.Значение;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

Процедура СохранитьНастройки() Экспорт
	Попытка
		// Ключом настроек должно быть не имя обработки, а полное имя метаданных, т.к. имя внешней обработки
		// может совпадать с именем обработки, встроенной в состав конфигурации
		ХранилищеОбщихНастроек.Сохранить(ЭтотОбъект.Метаданные().ПолноеИмя(), , ЭтотОбъект.Настройки);
	Исключение
		// TODO: При пакетном запуске и тестировании в тонком клиенте возникает ошибка типа XDTO
		// Могут возникнуть ошибки, пропускаем
	КонецПопытки;
КонецПроцедуры

Функция ПолучитьПустыеНастройкиБраузераТестирования()
	Результат = Новый Структура;
	Результат.Вставить("ИсторияЗагрузкиТестов", Новый Массив);
	
	Возврат Результат;
КонецФункции

Процедура СохранитьВИсториюЗагрузкиТестов(Знач ИдентификаторЗагрузчика, Знач Путь) Экспорт
	ИсторияЗагрузкиТестов = ЭтотОбъект.Настройки.ИсторияЗагрузкиТестов;
	Для Сч = - ИсторияЗагрузкиТестов.Количество() + 1 По 0 Цикл
		Индекс = -Сч;
		ЭлементИстории = ИсторияЗагрузкиТестов[Индекс];
		Если ЭлементИстории.ИдентификаторЗагрузчика = ИдентификаторЗагрузчика И ЭлементИстории.Путь = Путь Тогда
			ИсторияЗагрузкиТестов.Удалить(Индекс);
		КонецЕсли;
	КонецЦикла;
	
	ИсторияЗагрузкиТестов.Вставить(0, Новый Структура("ИдентификаторЗагрузчика, Путь", ИдентификаторЗагрузчика, Путь));
	ДлинаИстории = 10;
	Пока ИсторияЗагрузкиТестов.Количество() > ДлинаИстории Цикл
		ИсторияЗагрузкиТестов.Удалить(ДлинаИстории);
	КонецЦикла;
КонецПроцедуры

Функция ПутьФайлаНастроек() Экспорт
	Возврат ПутьФайлаНастроек;		
КонецФункции

// } Настройки браузера тестирования

// { Оповещения
Функция ВозможныеСобытия() Экспорт
	ИмяФреймворка = Метаданные().Имя;
	ВозможныеСобытия = Новый Структура;
	ВозможныеСобытия.Вставить("ВыполненТестовыйМетод", ИмяФреймворка + "_ВыполненТестовыйМетод");
	
	Возврат Новый ФиксированнаяСтруктура(ВозможныеСобытия);
КонецФункции

Процедура ОповеститьОСобытии(Знач Подписчик, Знач Событие, Знач ПараметрыСобытия)
	Выполнить("Подписчик.ОбработатьСобытиеВыполненияТестов(Событие, ПараметрыСобытия);");
КонецПроцедуры
// } Оповещения

// { Контекст
Процедура СохранитьКонтекст(Знач Контекст) Экспорт
	Если ЭтотОбъект.ТекущийКонтейнер.СлучайныйПорядокВыполнения Тогда
		ВызватьИсключение ЭтотОбъект.ВозможныеИсключения.СохранятьКонтекстТолькоВСтрогомРежиме;
	КонецЕсли;
	ЭтотОбъект.ТекущийКонтейнер.Контекст = Контекст;
КонецПроцедуры

Функция ПолучитьКонтекст() Экспорт
	Если ЭтотОбъект.ТекущийКонтейнер.СлучайныйПорядокВыполнения Тогда
		ВызватьИсключение ЭтотОбъект.ВозможныеИсключения.ПолучатьКонтекстТолькоВСтрогомРежиме;
	КонецЕсли;
	Возврат ЭтотОбъект.ТекущийКонтейнер.Контекст;
КонецФункции
// } Контекст

Процедура ВызватьОшибкуПроверки(СообщениеОшибки = "") Экспорт
	
	Префикс = "["+ СтатусыРезультатаТестирования.ОшибкаПроверки + "]";
	ВызватьИсключение Префикс + " " + СообщениеОшибки;
	
КонецПроцедуры

Процедура ПропуститьТест(Знач Сообщение = "") Экспорт
	
	Префикс = "[" + СтатусыРезультатаТестирования.ТестПропущен + "]";
	Если ПустаяСтрока(Сообщение) Тогда
		Сообщение = НСтр("ru = 'Тест пропущен'");
	КонецЕсли;
	ВызватьИсключение Префикс + " " + Сообщение;
	
КонецПроцедуры

// Выводит сообщение. В тестах ВСЕГДА должна использоваться ВМЕСТО метода Сообщить().
// 
Функция ВывестиСообщение(ТекстСообщения, Статус=Неопределено) Экспорт	
	
	Сообщить(ТекстСообщения, Статус);
	
КонецФункции

// { Helpers
Функция ВозможныеИсключения()
	ВозможныеИсключения = Новый Структура;
	ВозможныеИсключения.Вставить("СохранятьКонтекстТолькоВСтрогомРежиме", "Сохранять контекст можно только в рамках контейнеров со строгим порядком выполнения");
	ВозможныеИсключения.Вставить("ПолучатьКонтекстТолькоВСтрогомРежиме", "Получать контекст можно только в рамках контейнеров со строгим порядком выполнения");
	
	Возврат Новый ФиксированнаяСтруктура(ВозможныеИсключения);
КонецФункции

Функция ПеремешатьМассив(Знач ИсходныйМассив)
	Результат = Новый Массив;
	Для Каждого Элемент Из ИсходныйМассив Цикл
		Результат.Добавить(Элемент);
	КонецЦикла;
	
	// алгоритм перемешивания взят из книги Кнута "Искусство программирования" т.2
	ГСЧ = Новый ГенераторСлучайныхЧисел();
	ПоследнийИндекс = Результат.ВГраница();
	Для Индекс = 1 По ПоследнийИндекс Цикл
		ТекущийИндекс = ПоследнийИндекс - Индекс + 1;
		НовыйИндекс = ГСЧ.СлучайноеЧисло(0, ТекущийИндекс);
		Если НовыйИндекс <> ТекущийИндекс Тогда
			Значение = Результат[НовыйИндекс];
			Результат[НовыйИндекс] = Результат[ТекущийИндекс];
			Результат[ТекущийИндекс] = Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция НайтиРезультатТестированияПоИдентификатору(Знач КонтейнерРезультатовТестирования, Знач ИдентификаторТеста, Знач ВключатьПодчиненные = Ложь) Экспорт
	Перем Результат;
	
	Для каждого ДочернийРезультатТестирования Из КонтейнерРезультатовТестирования.Строки Цикл
		Если ДочернийРезультатТестирования.Ключ = ИдентификаторТеста Тогда
			Результат = ДочернийРезультатТестирования;
		ИначеЕсли ЗначениеЗаполнено(Результат) И ВключатьПодчиненные И ДочернийРезультатТестирования.Тип = ЭтотОбъект.ТипыУзловДереваТестов.Контейнер Тогда
			Результат = НайтиРезультатТестированияПоИдентификатору(ДочернийРезультатТестирования, ИдентификаторТеста, ВключатьПодчиненные);
		КонецЕсли;
		Если ЗначениеЗаполнено(Результат) Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция ПараметрыМетода(Знач Парам1, Знач Парам2 = Неопределено, Знач Парам3 = Неопределено, Знач Парам4 = Неопределено, Знач Парам5 = Неопределено, Знач Парам6 = Неопределено, Знач Парам7 = Неопределено, Знач Парам8 = Неопределено, Знач Парам9 = Неопределено) Экспорт
	ВсеПараметры = Новый Массив;
	ВсеПараметры.Добавить(Парам1);
	ВсеПараметры.Добавить(Парам2);
	ВсеПараметры.Добавить(Парам3);
	ВсеПараметры.Добавить(Парам4);
	ВсеПараметры.Добавить(Парам5);
	ВсеПараметры.Добавить(Парам6);
	ВсеПараметры.Добавить(Парам7);
	ВсеПараметры.Добавить(Парам8);
	ВсеПараметры.Добавить(Парам9);
	
	ИндексСПоследнимПараметром = 0;
	Для Сч = 0 По ВсеПараметры.ВГраница() Цикл
		Индекс = ВсеПараметры.ВГраница() - Сч;
		Если ВсеПараметры[Индекс] <> Неопределено Тогда
			ИндексСПоследнимПараметром = Индекс;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыМетода = Новый Массив;
	Для Сч = 0 По ИндексСПоследнимПараметром Цикл
		ПараметрыМетода.Добавить(ВсеПараметры[Сч]);
	КонецЦикла;
	
	Возврат ПараметрыМетода;
КонецФункции
// } Helpers

// { Подсистема конфигурации xUnitFor1C

Функция ПолучитьГлавнуюПодсистему() Экспорт
	
	КоллекцияПодсистем = Метаданные.Подсистемы;
	
	ГлавнаяПодсистема = Неопределено;
	
	ИмяГлавнойПодсистемы = ИспользуемыйПрефиксПодсистемы + "xUnitFor1C";
	Для Каждого Подсистема Из КоллекцияПодсистем Цикл
		Если Подсистема.Имя = ИмяГлавнойПодсистемы Тогда
			ГлавнаяПодсистема = Подсистема;
			Прервать;
		Иначе
			ГлавнаяПодсистема = НайтиПодсистемуПоИмени(Подсистема.Подсистемы, ИмяГлавнойПодсистемы);	
			Если ТипЗнч(ГлавнаяПодсистема) = Тип("ОбъектМетаданных") Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если ГлавнаяПодсистема = Неопределено Тогда
		ВызватьИсключение "Не удалось главную подсистему """ + ИмяГлавнойПодсистемы + """!";
	КонецЕсли;
	
	Возврат ГлавнаяПодсистема;
	
КонецФункции

Функция НайтиПодсистемуПоИмени(КоллекцияПодсистем, ИмяПодсистемыДляПоиска)
	
	Для Каждого Подсистема Из КоллекцияПодсистем Цикл
		Если Подсистема.Имя = ИмяПодсистемыДляПоиска Тогда
			Возврат Подсистема;
		Иначе
			Возврат НайтиПодсистемуПоИмени(Подсистема.Подсистемы, ИмяПодсистемыДляПоиска);	
		КонецЕсли;
	КонецЦикла;
	
КонецФункции

Функция ПолучитьПлагины() Экспорт
	
	ГлавнаяПодсистема = ПолучитьГлавнуюПодсистему();
	
	СтруктураПлагинов = Новый Структура;
	
	ДлинаПрефикса = СтрДлина(ИспользуемыйПрефиксПодсистемы);
	РезультатПоиска = ГлавнаяПодсистема.Подсистемы.Найти("Plugins");
	Если РезультатПоиска = Неопределено Тогда
		ВызватьИсключение НСтр(
			"ru = 'Подсистему ""Plugins"" не удалось найти или она не подчинена подсистеме ""xUnitFor1C""'");	
	КонецЕсли;
	
	КоллекцияПлагинов = РезультатПоиска.Состав;
	Для Каждого Плагин Из КоллекцияПлагинов Цикл		
		ИмяПлагина = Прав(Плагин.Имя, СтрДлина(Плагин.Имя) - ДлинаПрефикса);
		СтруктураПлагинов.Вставить(ИмяПлагина, Плагин.Имя);	
	КонецЦикла;
	
	Возврат СтруктураПлагинов;
	
КонецФункции

Функция ПолучитьУтилиты() Экспорт
	
	ГлавнаяПодсистема = ПолучитьГлавнуюПодсистему();
	
	СтруктураПлагинов = Новый Структура;
	
	ДлинаПрефикса = СтрДлина(ИспользуемыйПрефиксПодсистемы);
	
	КоллекцияПлагинов = ГлавнаяПодсистема.Подсистемы.Utils.Состав;
	Для Каждого Плагин Из КоллекцияПлагинов Цикл		
		ИмяПлагина = Прав(Плагин.Имя, СтрДлина(Плагин.Имя) - ДлинаПрефикса);
		СтруктураПлагинов.Вставить(ИмяПлагина, Плагин.Имя);	
	КонецЦикла;
	
	Возврат СтруктураПлагинов;
	
КонецФункции

Функция ОбработкаЯвляетсяВстроеннойВКонфигурацию() Экспорт
	
	ПолноеИмяТекущейОбработки = ЭтотОбъект.Метаданные().ПолноеИмя();
	ВстроеннаяВКонфигурациюОбработка = Метаданные.НайтиПоПолномуИмени(ПолноеИмяТекущейОбработки); 
	
	ОбработкаВстроенаяВСоставКонфигурации = НЕ (ВстроеннаяВКонфигурациюОбработка = Неопределено); 
	
	Возврат ОбработкаВстроенаяВСоставКонфигурации;
	
КонецФункции

Функция СлужебныеПараметрыОбработки() Экспорт
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("ПолноеИмяБраузераТестов", ПолноеИмяБраузераТестов);
	СтруктураПараметров.Вставить("ПолныйПутьКФайлуБраузераТестов", ПолныйПутьКФайлуБраузераТестов);
	
	Возврат СтруктураПараметров;
	
КонецФункции

// Универсальная функция для проверки наличия 
// свойств у значения любого типа данных
// Переменные:
// 1. Переменная - переменная любого типа, 
// для которой необходимо проверить наличие свойства
// 2. ИмяСвойства - переменная типа "Строка", 
// содержащая искомое свойства
// 
Функция ПеременнаяСодержитСвойство(Переменная, ИмяСвойства)
     // Инициализируем структуру для теста 
     // с ключом (значение переменной "ИмяСвойства") 
     // и значением произвольного GUID'а
     GUIDПроверка = Новый УникальныйИдентификатор;
     СтруктураПроверка = Новый Структура;
     СтруктураПроверка.Вставить(ИмяСвойства, GUIDПроверка);
     // Заполняем созданную структуру из переданного 
     // значения переменной
     ЗаполнитьЗначенияСвойств(СтруктураПроверка, Переменная);
     // Если значение для свойства структуры осталось 
     // NULL, то искомое свойство не найдено, 
     // и наоборот.
     Если СтруктураПроверка[ИмяСвойства] = GUIDПроверка Тогда
          Возврат Ложь;
     Иначе
          Возврат Истина;
     КонецЕсли;
КонецФункции
Функция ЗаполнитьСвойствоПриНаличии(ОбъектЗаполнения, ИмяСвойство, ЗначениеСвойства)
	
	Если ПеременнаяСодержитСвойство(ОбъектЗаполнения, ИмяСвойство) Тогда
		ОбъектЗаполнения[ИмяСвойство] = ЗначениеСвойства;
	КонецЕсли;
	
КонецФункции

Функция ДополнитьИдентификаторПрефиксомПодсистемы(Знач Идентификатор) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ИспользуемыйПрефиксПодсистемы) Тогда
		Возврат Идентификатор;
	КонецЕсли;
	
	ДлинаПрефикса = СтрДлина(ИспользуемыйПрефиксПодсистемы);
	Если Лев(Идентификатор, ДлинаПрефикса) = ИспользуемыйПрефиксПодсистемы Тогда
		Возврат Идентификатор;			
	Иначе		
		Возврат ИспользуемыйПрефиксПодсистемы + Идентификатор;
	КонецЕсли;
	
КонецФункции
Функция ПолучитьИдентификаторБезПрефиксаПодсистемы(Знач Идентификатор) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ИспользуемыйПрефиксПодсистемы) Тогда
		Возврат Идентификатор;
	КонецЕсли;
	
	ДлинаПрефикса = СтрДлина(ИспользуемыйПрефиксПодсистемы);
	Если Лев(Идентификатор, ДлинаПрефикса) = ИспользуемыйПрефиксПодсистемы Тогда
		Возврат Прав(Идентификатор, СтрДлина(Идентификатор) - ДлинаПрефикса);		
	Иначе 
		Возврат Идентификатор;
	КонецЕсли;
	
КонецФункции

Функция СоздатьОбъектПлагина(Идентификатор, ВстроенаВКонфигурацию = Ложь, ЭтоОтчет = Ложь) Экспорт
	
	ОбъектПлагина = Неопределено;
	
	Если ЭтотОбъект.ЭтоВстроеннаяОбработка
		ИЛИ ВстроенаВКонфигурацию = Истина Тогда
		
		ИдентификаторСПрефиксомПодсистемы = ДополнитьИдентификаторПрефиксомПодсистемы(Идентификатор); 
		ИдентификаторБезПрефиксаПодсистемы = ПолучитьИдентификаторБезПрефиксаПодсистемы(Идентификатор);
		
		Если ЭтоОтчет = Истина Тогда
			МенеджерВидаОбъектов = Отчеты;
			МетаданныеВидаОбъектов = Метаданные.Отчеты;
		Иначе
			МенеджерВидаОбъектов = Обработки;
			МетаданныеВидаОбъектов = Метаданные.Обработки;
		КонецЕсли;
		
		Если НЕ МетаданныеВидаОбъектов.Найти(ИдентификаторСПрефиксомПодсистемы) = Неопределено Тогда
			ОбъектПлагина = МенеджерВидаОбъектов[ИдентификаторСПрефиксомПодсистемы].Создать();
		ИначеЕсли НЕ МетаданныеВидаОбъектов.Найти(ИдентификаторБезПрефиксаПодсистемы) = Неопределено Тогда
			ОбъектПлагина = МенеджерВидаОбъектов[ИдентификаторБезПрефиксаПодсистемы].Создать();
		КонецЕсли;
		
	КонецЕсли;
		
	Если ОбъектПлагина = Неопределено Тогда
		Если ЭтоОтчет = Истина Тогда
			ОбъектПлагина = ВнешниеОтчеты.Создать(Идентификатор, Ложь);				
		Иначе
			ОбъектПлагина = ВнешниеОбработки.Создать(Идентификатор, Ложь);	
		КонецЕсли;
	КонецЕсли;
	
	Возврат ОбъектПлагина;
	
КонецФункции

// } Подсистема конфигурации xUnitFor1C

Инициализация();