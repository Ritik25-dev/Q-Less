import React from 'react'
import ItemView from './components/ItemView'
import './AdminPanel.css'
import FoodTrend from './components/FoodTrend'
import Navbar from './components/Navbar'

const AdminPanel = () => {
  return (
    <div className='adminPannel'>
        <Navbar/>
        <div className='bottom'>
            <ItemView/>
            <FoodTrend/>
        </div>
        
    </div>
  )
}

export default AdminPanel