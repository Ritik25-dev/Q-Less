// routes/authRoutes.js
import express from 'express';
import { register, verifyOtp, login , resendOtp, adminLogin, getAdmin, kitchenStatus } from '../controller/authController.js';
import { verifyJwt } from '../middleware/authMiddleware.js';

const router = express.Router();

router.post('/register', register);
router.post('/verifyOtp', verifyOtp);
router.post('/login', login);
router.post('/resend-otp', resendOtp);

router.post('/adminlogin', adminLogin);
router.post('/updateKitchen', kitchenStatus);

router.get('/getAdmin',verifyJwt, getAdmin);

export default router;