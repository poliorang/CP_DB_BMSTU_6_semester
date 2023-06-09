import matplotlib.pyplot as plt

def plot():
    len_arr = [10,       25,       50,       100,      250,      500,      750,       1000]
    result1 = [0.131317, 0.175450, 0.411645, 0.877204, 2.205371, 6.079674, 12.083022, 18.278156]
    result2 = [0.010210, 0.058736, 0.047920, 0.107326, 0.174752, 0.181720, 0.2716641, 0.4308143]


    fig1 = plt.figure(figsize=(10, 7))
    plot = fig1.add_subplot()
    plot.plot(len_arr, result1, '-o', label="Получение участников соревнования")
    plot.plot(len_arr, result2, '-ro', label="Добавление улова")
    plt.legend()
    plt.grid()
    plt.title("Зависимость времени работы функций от количества участников")
    plt.xlabel("Количество участников")
    plt.ylabel("Время (с)")

    plt.show()
    # plt.savefig('Plot.png')


if __name__ == "__main__":
    plot()
