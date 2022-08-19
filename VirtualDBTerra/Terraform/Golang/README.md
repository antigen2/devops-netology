# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

### Ответ
```bash
antigen@kenny:~$ wget https://go.dev/dl/go1.19.linux-amd64.tar.gz
antigen@kenny:~$ sudo mkdir -p /opt/golang/1.19
antigen@kenny:~$ tar -C /opt/golang/1.19 -xzf go1.19.linux-amd64.tar.gz
antigen@kenny:~$ echo "PATH=$PATH:/opt/golang/1.19/go/bin" >> .profile
antigen@kenny:~$ source .profile
antigen@kenny:~$ go version
go version go1.19 linux/amd64
```

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```
 
1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код. 

### Ответ
1.
```go
package main

import "fmt"

func m_to_ft(m float64) float64 {
	return m * 3.2808
}

func main() {

	fmt.Print("Введите кол-во метров: ")
	var m float64
	fmt.Scanf("%f", &m)

	f := m_to_ft(m)
	fmt.Printf("%g метр(a/ов) - это %g фут(a/ов)\n", m, f)
}
```
2.
```go
package main

import "fmt"

func min(ar []int) (minimum int) {
	minimum = ar[0]
	for _, value := range ar {
		if minimum <= value {
			continue
		}
		minimum = value
	}
	return
}

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	m := min(x)
	fmt.Print("Минимальный элемент в массиве ", x, "  -->  ", m, "\n")
}
```
3.
```go
package main

import "fmt"

func div(min, max, divider int) []int {
	var res []int
	for i := min; i <= max; i++ {
		if i%divider == 0 {
			res = append(res, i)
		}
	}
	return res
}

func main() {
	div_3 := div(1, 100, 3)
	fmt.Println(div_3)
}
```

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

