using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace TestRunner
{
    class Program
    {
        public static void Main(string[] args)
        {
            var count = Directory.GetFiles(Directory.GetCurrentDirectory()).Select(Path.GetFileName).Count(x => Regex.IsMatch(x!, @"test.*\.txt$"));
            Console.WriteLine(count);
            List<string> JSONout = new List<string>();
            string program = "output"; // Название исполняемого файла
            int number_of_tests = count;    // Количество тестов
            // Файлы тестов имеют вид test{k} 
            // Файлы ответов имеют вид answer{k} 
            // Где k = [1 ... n] (n = number_of_tests)

            for (int test_number = 1; test_number <= number_of_tests; ++test_number)
            {
                string input_file = "test" + test_number.ToString() + ".txt";    // Генерируем название файла с входными данными
                string answer_file = "answer" + test_number.ToString() + ".txt"; // Генерируем название файла с правильным ответом

                if (!File.Exists(input_file))                                    // Проверяем, что файл с тестом существует
                {
                    Console.WriteLine($"Test file {input_file} does not exist");
                    return;
                }
                if (!File.Exists(answer_file))                                   // Проверяем, что файл с ответом существует
                {
                    Console.WriteLine($"Test file {answer_file} does not exist");
                    return;
                }

                string program_answer = RunProjectOnTest(program, input_file);   // Запускаем програму на тесте

                string real_answer = File.ReadAllText(answer_file);              // Читаем правельный ответ

                Console.WriteLine($"Test {test_number}:\nReal answer:\n" +
                    $"{real_answer}\nProgram answer:\n{program_answer}");       // Вывод ответов

                if (real_answer == program_answer)                               // Проверка ответа
                { // Вывод положительного результата
                    string outt = $"Test{test_number} = OK";
                    JSONout.Add(outt);
                }
                else
                { // Вывод отрицательного результата
                    string outt = $"Test{test_number} = WA";
                    JSONout.Add(outt);
                }
            }
            JsonOutput(JSONout);
        }

        public static void JsonOutput(List<string> JSONout)
        {
            DataContractJsonSerializer serializer = new
                DataContractJsonSerializer(typeof(List<string>));
            using (FileStream fs = new FileStream("out.json", FileMode.Create))
            {
                serializer.WriteObject(fs, JSONout);
            }
        }

        static string RunProjectOnTest(string programm_name, string test_file)
        {
            Process process = new Process();

            process.StartInfo.FileName = programm_name;                             // имя исполняемого файла 
            process.StartInfo.RedirectStandardInput = true;                         // Отвязываем наш вход от входа программы
            process.StartInfo.RedirectStandardOutput = true;                        // Отвязываем наш выход от входа программы

            process.Start();                                                        // запуск 

            StreamWriter process_input = process.StandardInput;                     // получения потока программы на вход
            List<string> input = new List<string>(File.ReadAllLines(test_file));    // Считываем входные данные
            foreach(string line in input)
            {
                process_input.WriteLine(line);                                      // Передаем программе ввод построчно
            }

            string output = process.StandardOutput.ReadToEnd();                     // Чтение вывода 
            //Console.WriteLine(output);                                            // Вывод на консоль результатов
            process.WaitForExit();                                                  // Ожидание завершения

            return output;
        }
    }
}