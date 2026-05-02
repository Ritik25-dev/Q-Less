import User from '../models/user.js';
import Otp from '../models/Otp.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { sendOTP } from '../utils/sendEmail.js';
import Admin from '../models/admin.js';
import KitchenStatus from '../models/kitchenStatus.js';


const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

const generateAccessAndRefreshToken = async (id) =>{

    const accessToken = jwt.sign({
        id: id  
    }, process.env.ACCESS_TOKEN_SECRET , { expiresIn: '15h' });

    const refreshToken = jwt.sign({
    id: id
    }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '30d' } );
    return {accessToken,refreshToken}
}

export const register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    let user = await User.findOne({ email });
    if (user && user.isVerified) {
      return res.status(400).json({ message: 'User already exists and is verified.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    if (user) {
      user.name = name;
      user.phone = phone;
      user.password = hashedPassword;
      await user.save();
    } else {
      user = new User({ name, email, phone, password: hashedPassword });
      await user.save();
    }

    const otpCode = generateOTP();
    await Otp.deleteMany({ email });
    await Otp.create({ email, otp: otpCode });

    await sendOTP(email, otpCode);

    res.status(200).json({ message: 'OTP sent to your email. Please verify.' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};


export const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    console.log(otp)

    const otpRecord = await Otp.findOne({ email, otp });
    if (!otpRecord) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }

    const user = await User.findOneAndUpdate({ email }, { isVerified: true }, { new: true });
    
    await Otp.deleteOne({ email, otp });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.status(200).json({ 
      message: 'Account verified successfully', 
      token, 
      user: { id: user._id, name: user.name, email: user.email } 
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};


export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }


    if (!user.isVerified) {
      return res.status(403).json({ message: 'Please verify your account via OTP first.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.status(200).json({
      message: 'Login successful',
      token,
      user: { id: user._id, name: user.name, email: user.email, phone: user.phone }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};



export const resendOtp = async (req, res) => {
  try {
    const { email } = req.body;

  
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found. Please register first.' });
    }

  
    if (user.isVerified) {
      return res.status(400).json({ message: 'User is already verified. You can log in.' });
    }

    
    await Otp.deleteMany({ email });

   
    const newOtpCode = generateOTP();
    await Otp.create({ email, otp: newOtpCode });

    await sendOTP(email, newOtpCode);

    res.status(200).json({ message: 'A new OTP has been sent to your email.' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

export const adminLogin = async (req,res)=>{
  try{
    const {email,password}= req.body;

    if(!email || !password) return res.status(404).json({message:'Email and Password required'})

    const admin = await Admin.findOne({email:email});

    if(!admin) return res.status(403).json({message:'Invalid Request'})

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const tokens = await generateAccessAndRefreshToken(admin._id) 
      await Admin.updateOne({_id:admin._id},{refreshToken:tokens.refreshToken}) 
      const refreshTokenOptions = {
          httpOnly: true,
          secure:true,
          sameSite: 'None',
          maxAge: 30 * 24 * 60 * 60 * 1000
      };
      const accessTokenOptions = {
          httpOnly: true,
          secure:true,
          sameSite: 'None',
          maxAge: 15 * 60 * 60 * 1000
      };

      const loggedInAdmin = await Admin.findById(admin._id).select('role')

      return res.status(200)
            .cookie("accessToken", tokens.accessToken, accessTokenOptions)
            .cookie("refreshToken", tokens.refreshToken, refreshTokenOptions)
            .json(loggedInAdmin)

    
  }catch(error){
    res.status(500).json({ message: 'Server error', error: error.message });
  }
}

export const getAdmin = async (req,res)=>{
  try{
    const admin = req.admin

    return res.status(200).json(admin)
  }catch(error){
    res.status(500).json({ message: 'Server error', error: error.message });
  }
}

export const kitchenStatus = async(req,res)=>{
  try{
    const {status} = req.body;
    console.log(status)

    const today = new Date();
    today.setUTCHours(0,0,0,0)

    const isKitchen = await KitchenStatus.findOne({date:today})

    if(isKitchen){
      isKitchen.open = status

      await isKitchen.save()
      return res.status(200).json({message:`Kitchen status updated to ${status?'Open':'Close'}`})
    }

    const data = {
      date:today,
      open:status,
      orderNo:1
    }

    const final = new KitchenStatus(data)
    await final.save()

    return res.status(200).json({message:`Kitchen is ${status?'Open':'Close'}`})

  }catch(error){
    console.log(error)
    res.status(500).json({ message: 'Server error', error: error.message });
  }
}