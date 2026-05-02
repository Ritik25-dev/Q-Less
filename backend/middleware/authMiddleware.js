import jwt from 'jsonwebtoken';
import User from '../models/user.js';
import Admin from '../models/admin.js';

export const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];

      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      req.user = await User.findById(decoded.id).select('-password');
      next();
    } catch (error) {
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  } else {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};

export const verifyJwt = async (req,res,next) =>{
    const accessToken = req?.cookies?.accessToken;
    const refreshToken = req?.cookies?.refreshToken;
    try{
        if(!refreshToken) return res.status(403).json({message:'Unauthorized or expired session'})
        if(!accessToken) return res.status(401).json({message:'Unauthorized or expired session'})
        const decodedToken = jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET);
        const id = decodedToken.id

        const admin = await Admin.findById(id).select('-password')

        if(!admin) return res.status(401).json({mesaage:'Unauthorized Request'})

        req.admin = admin
        
        next();
    }catch(err){
        res.status(401).json({message:'Unauthorized or expired session'})
        console.log(err)
    }
}