using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using Microsoft.Win32;

namespace MSILBlockerLab.Demo;

internal static class Program
{
    private const string Tag = "MSILBlockerLab";
    [STAThread]
    private static void Main()
    {
        // Safe training source, not a malware sample. No screen or keyboard lock.
        string root = Path.Combine(Environment.GetFolderPath(
            Environment.SpecialFolder.LocalApplicationData), Tag);
        Directory.CreateDirectory(root);
        File.WriteAllText(Path.Combine(root, "MSILBlockerLab-dotnet-artifact.txt"),
            $"Safe .NET Sysmon demonstration {DateTime.UtcNow:O}{Environment.NewLine}");
        using (RegistryKey? key = Registry.CurrentUser.CreateSubKey(@"Software\MSILBlockerLab"))
        {
            key?.SetValue("MSILBlockerLab-DotNetTag",
                "benign-managed-code-demo", RegistryValueKind.String);
        }
        ApplicationConfiguration.Initialize();
        var window = new Form {
            Text = "MSILBlockerLab | Safe .NET Demo",
            Size = new Size(620, 290),
            StartPosition = FormStartPosition.CenterScreen,
            MaximizeBox = false, TopMost = false
        };
        var title = new Label {
            Text = "EDUCATIONAL .NET DETECTION LAB",
            Location = new Point(25, 25), Size = new Size(550, 40),
            Font = new Font("Segoe UI", 14, FontStyle.Bold)
        };
        var details = new Label {
            Text = "This closeable application creates a local text file\n"
                + "and a harmless user registry value for Sysmon monitoring.\n\n"
                + "No encryption, screen lock, network access, or persistence.",
            Location = new Point(25, 83), Size = new Size(550, 94)
        };
        var close = new Button {
            Text = "Close demo", Location = new Point(25, 185),
            Size = new Size(170, 35)
        };
        close.Click += (_, _) => window.Close();
        window.Controls.Add(title);
        window.Controls.Add(details);
        window.Controls.Add(close);
        Application.Run(window);
    }
}
