import './AdminDashBoard.css';
import DeliveredView from './components/DeliveredView';
import Pendingview from './components/Pendingview';
import ReadyView from './components/ReadyView';
import { styled } from '@mui/material/styles';
import FormGroup from '@mui/material/FormGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import Switch from '@mui/material/Switch';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useEffect, useState } from 'react';
import { toast } from 'react-toastify';
import { useMutation } from '@tanstack/react-query';
import { kitchenStatusUpdate } from './api/post.api';



const AdminDashboard = () => {

  const IOSSwitch = styled((props) => (
      <Switch focusVisibleClassName=".Mui-focusVisible" disableRipple {...props} />
    ))(({ theme }) => ({
      width: 42,
      height: 26,
      padding: 0,
      '& .MuiSwitch-switchBase': {
        padding: 0,
        margin: 2,
        transitionDuration: '300ms',
        '&.Mui-checked': {
          transform: 'translateX(16px)',
          color: '#fff',
          '& + .MuiSwitch-track': {
            backgroundColor: '#65C466',
            opacity: 1,
            border: 0,
            ...theme.applyStyles('dark', {
              backgroundColor: '#2ECA45',
            }),
          },
          '&.Mui-disabled + .MuiSwitch-track': {
            opacity: 0.5,
          },
        },
        '&.Mui-focusVisible .MuiSwitch-thumb': {
          color: '#33cf4d',
          border: '6px solid #fff',
        },
        '&.Mui-disabled .MuiSwitch-thumb': {
          color: theme.palette.grey[100],
          ...theme.applyStyles('dark', {
            color: theme.palette.grey[600],
          }),
        },
        '&.Mui-disabled + .MuiSwitch-track': {
          opacity: 0.7,
          ...theme.applyStyles('dark', {
            opacity: 0.3,
          }),
        },
      },
      '& .MuiSwitch-thumb': {
        boxSizing: 'border-box',
        width: 22,
        height: 22,
      },
      '& .MuiSwitch-track': {
        borderRadius: 26 / 2,
        backgroundColor: '#E9E9EA',
        opacity: 1,
        transition: theme.transitions.create(['background-color'], {
          duration: 500,
        }),
        ...theme.applyStyles('dark', {
          backgroundColor: '#39393D',
        }),
      },
    }));

    const [kitchenStatus,setKitchenStatus] = useState(false)

    const updateKitchenMutation = useMutation({
      mutationFn: (status) => kitchenStatusUpdate(status),
      onSuccess: (data) =>{
        toast.success(data.message)
      }
    })

    const handleChange = (e)=>{
      setKitchenStatus(e.target.checked)
    }

    useEffect(()=>{
      updateKitchenMutation.mutate(kitchenStatus)
    },[kitchenStatus])

  return ( 
    <div className="admin-container">
        <div className="admin-header">
            <h1 style={{margin: 0, fontWeight: 900}}>Q-Less</h1>
            <div className="liveBtn">
              <FormControlLabel
                control={<IOSSwitch sx={{ m: 1 }}  onChange={handleChange} checked={kitchenStatus}/>}
                label={kitchenStatus?'Live':'Go Live'}
              />
            </div>
        </div>
          <div className="adminBody">
            <Pendingview />
            <ReadyView/>
            <DeliveredView/>
          </div>
        
    </div>
  );
};


export default AdminDashboard;