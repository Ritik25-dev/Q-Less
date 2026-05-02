import React, { useState } from 'react';
import './Login.css';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { login } from './api/post.api';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';

const Login = () => {
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const loginMutation = useMutation({
    mutationFn: (data) => login(data),
    onSuccess: (data) => {
        queryClient.invalidateQueries({queryKey:['admin']})
        
        toast.success("Login Successful");

        if(data?.role === 'Admin'){
            navigate('/admin');
        } else if(data?.role === 'Staff'){ 
            navigate('/dashboard');
        }
    },
    onError: (error) =>{
        toast.error(error.message || "Login failed");
    }
  })

  const handleSubmit = (e)=>{
    e.preventDefault()
    if(!email || !password){
        toast.error('Email and Password are required')
        return
    }
    loginMutation.mutate({email, password})
  }

  return (
    <div className="login-wrapper">
      <div className="login-box">
        <div className="login-header">
          <h1>Q-Less</h1>
          <p>Sign in to access your dashboard</p>
        </div>

        <form className="login-form" onSubmit={handleSubmit}>
          <div className="input-field">
            <label>Email Address</label>
            <input 
              type="email" 
              value={email} 
              onChange={(e) => setEmail(e.target.value)} 
              placeholder="admin@smartorder.com"
            />
          </div>

          <div className="input-field">
            <label>Password</label>
            <input 
              type="password" 
              value={password} 
              onChange={(e) => setPassword(e.target.value)} 
              placeholder="••••••••"
            />
          </div>

          <button type="submit" className="signin-button" disabled={loginMutation.isPending}>
            {loginMutation.isPending ? 'Signing In...' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;