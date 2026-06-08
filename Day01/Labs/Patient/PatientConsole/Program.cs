//Console.WriteLine("=== Patient Portal Self-Registration ===");

//Console.Write("Enter patient age: ");

//string? input = Console.ReadLine();

//if (int.TryParse(input, out int age))
//{
//    if (age >= 18)
//        Console.WriteLine("Eligible: patient may self-register.");
//    else
//        Console.WriteLine("Not eligible: a guardian must register this patient.");
//}
//else
//{
//    Console.WriteLine("Invalid input: age must be a whole number.");
//}


Console.Write("Enter patient weight (kg): ");

string? raw = Console.ReadLine();

try
{
    double weight = double.Parse(raw!);   // throws if not a number

    if (weight <= 0)
        throw new ArgumentException("Weight must be positive.");

    Console.WriteLine($"Recorded weight: {weight} kg");
}
catch (FormatException)
{
    Console.WriteLine("Input was not a valid number.");
}
catch (ArgumentException ex)
{
    Console.WriteLine($"Invalid value: {ex.Message}");
}
finally
{
    Console.WriteLine("Weight entry step complete.");
}

