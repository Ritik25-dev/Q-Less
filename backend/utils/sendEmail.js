import SibApiV3Sdk from 'sib-api-v3-sdk';
import dotenv from 'dotenv';

dotenv.config();

const client = SibApiV3Sdk.ApiClient.instance;
const apiKey = client.authentications['api-key'];
apiKey.apiKey = process.env.BREVO_API_KEY; 

const tranEmailApi = new SibApiV3Sdk.TransactionalEmailsApi();

export const sendOTP = async (email, otp) => {
  const sendSmtpEmail = new SibApiV3Sdk.SendSmtpEmail();

  sendSmtpEmail.sender = { email: 'noreply.hansrajconnect@gmail.com', name: 'Q-less Canteen' };
  sendSmtpEmail.to = [{ email: email }];
  sendSmtpEmail.subject = 'Your Q-less Verification Code';
  sendSmtpEmail.textContent = `Your OTP for registration is: ${otp}. It is valid for 5 minutes.`;
  sendSmtpEmail.htmlContent = `
    <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
        <h2>Welcome to Q-less!</h2>
        <p>Your OTP for registration is:</p>
        <h1 style="color: #E23744; letter-spacing: 5px;">${otp}</h1>
        <p>It is valid for 5 minutes.</p>
    </div>
  `;

  try {
    const result = await tranEmailApi.sendTransacEmail(sendSmtpEmail);
    console.log('OTP Email sent successfully via Brevo SDK. Message ID:', result.messageId);
  } catch (error) {
    console.error('Error sending email:', error);
    throw new Error('Failed to send OTP email');
  }
};