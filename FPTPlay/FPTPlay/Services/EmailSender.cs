using MimeKit;
using MailKit.Net.Smtp;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace FPTPlay.Services
{
    public interface IEmailSender
    {
        Task SendEmailAsync(string email, string subject, string htmlMessage);
    }

    public class EmailSender : IEmailSender
    {
        private readonly IConfiguration _config;

        public EmailSender(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            var emailMessage = new MimeMessage();
            emailMessage.From.Add(new MailboxAddress("FPT Play System", _config["Smtp:User"]));
            emailMessage.To.Add(new MailboxAddress("", email));
            emailMessage.Subject = subject;

            var bodyBuilder = new BodyBuilder { HtmlBody = htmlMessage };
            emailMessage.Body = bodyBuilder.ToMessageBody();

            using (var client = new SmtpClient())
            {
                try
                {
                    client.ServerCertificateValidationCallback = (s, c, h, e) => true; // Bypass dev cert issues
                    await client.ConnectAsync(_config["Smtp:Host"], int.Parse(_config["Smtp:Port"]), MailKit.Security.SecureSocketOptions.StartTls);
                    await client.AuthenticateAsync(_config["Smtp:User"], _config["Smtp:Pass"]);
                    await client.SendAsync(emailMessage);
                    await client.DisconnectAsync(true);
                }
                catch
                {
                    // Fail silently in development
                }
            }
        }
    }
}
